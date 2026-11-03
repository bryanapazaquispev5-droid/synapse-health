const element = (id) => document.getElementById(id);
const status = element('connection-status');
const tablesElement = element('tables');
const itemsElement = element('items');
const usersElement = element('users');
const tableMenuToggle = element('table-menu-toggle');
let tableLoadId = 0;
let selectedTableName = null;
const tableLabels = [
  ['medical-areas', 'Áreas médicas'], ['topics', 'Temas'], ['quizzes', 'Quizzes'],
  ['study-notes', 'Study Notes'], ['user-profiles', 'Perfiles de usuario'],
  ['user-progress', 'Progreso de usuarios'], ['leaderboard', 'Ranking'],
  ['user-devices', 'Dispositivos legacy (inactivos)'], ['rate-limits', 'Límites de solicitudes'],
];

function tableLabel(tableName) {
  if (tableName.endsWith('-AppTable') || tableName.includes('-AppTable-')) return 'Tabla anterior (respaldo)';
  const match = tableLabels.find(([suffix]) => tableName.endsWith(`-${suffix}`));
  return match?.[1] ?? 'Otra tabla';
}

async function requestJson(path) {
  const response = await fetch(path, {cache: 'no-store'});
  const result = await response.json();
  if (!response.ok) throw new Error(result.message || 'No se pudo consultar AWS.');
  return result;
}

function showError(target, error) {
  target.replaceChildren();
  const message = document.createElement('p');
  message.className = 'muted';
  message.textContent = error.message;
  target.append(message);
}

function flatItem(item) {
  const flat = {};
  for (const [key, value] of Object.entries(item)) {
    if (key === 'data' && value && typeof value === 'object' && !Array.isArray(value)) {
      for (const [field, fieldValue] of Object.entries(value)) flat[`data.${field}`] = fieldValue;
    } else {
      flat[key] = value;
    }
  }
  return flat;
}

function tableCell(value) {
  const cell = document.createElement('td');
  if (value === null || value === undefined) {
    cell.textContent = '—';
  } else if (typeof value === 'object') {
    const details = document.createElement('details');
    const summary = document.createElement('summary');
    summary.textContent = Array.isArray(value) ? `${value.length} valores · ver` : 'Ver contenido';
    const content = document.createElement('pre');
    content.textContent = JSON.stringify(value, null, 2);
    details.append(summary, content);
    cell.append(details);
  } else {
    cell.textContent = String(value);
  }
  return cell;
}

function createDataTable(columns, rows) {
  const wrapper = document.createElement('div');
  wrapper.className = 'data-table-wrap';
  const table = document.createElement('table');
  table.className = 'data-table';
  const head = document.createElement('thead');
  const headerRow = document.createElement('tr');
  for (const column of columns) {
    const cell = document.createElement('th');
    cell.scope = 'col';
    cell.textContent = column;
    headerRow.append(cell);
  }
  head.append(headerRow);
  const body = document.createElement('tbody');
  for (const row of rows) {
    const tableRow = document.createElement('tr');
    for (const column of columns) tableRow.append(tableCell(row[column]));
    body.append(tableRow);
  }
  table.append(head, body);
  wrapper.append(table);
  return wrapper;
}

function renderItems(page) {
  const toolbar = document.createElement('div');
  toolbar.className = 'items-toolbar';
  const count = document.createElement('span');
  count.textContent = `${tableLabel(page.tableName)} · ${page.items.length} filas · ${page.consumedCapacity.toFixed(1)} RCU leídas`;
  toolbar.append(count);
  itemsElement.replaceChildren(toolbar);
  if (!page.items.length) {
    itemsElement.append(document.createTextNode('Esta tabla no tiene elementos.'));
  } else {
    const rows = page.items.map(flatItem);
    const columns = [...new Set(rows.flatMap(row => Object.keys(row)))];
    columns.sort((left, right) => {
      const priority = name => name === 'PK' ? 0 : name === 'SK' ? 1 : 2;
      return priority(left) - priority(right) || left.localeCompare(right);
    });
    itemsElement.append(createDataTable(columns, rows));
  }
}

function showTableMenu(isOpen) {
  tablesElement.hidden = !isOpen;
  tableMenuToggle.setAttribute('aria-expanded', String(isOpen));
}

function pauseBetweenScans() {
  return new Promise(resolve => window.setTimeout(resolve, 500));
}

async function loadTable(tableName) {
  const loadId = ++tableLoadId;
  selectedTableName = tableName;
  element('selected-table-name').textContent = tableLabel(tableName);
  element('selected-table-id').textContent = tableName;
  showTableMenu(false);
  itemsElement.textContent = 'Leyendo todos los datos…';
  const path = `/api/tables/${encodeURIComponent(tableName)}/items`;
  const items = [];
  let cursor = null;
  let consumedCapacity = 0;
  try {
    do {
      const requestPath = cursor
        ? `${path}?cursor=${encodeURIComponent(cursor)}`
        : path;
      const page = await requestJson(requestPath);
      if (loadId !== tableLoadId) return;
      items.push(...page.items);
      cursor = page.nextCursor;
      consumedCapacity += page.consumedCapacity;
      itemsElement.textContent = cursor
        ? `Cargando todos los datos… ${items.length} filas leídas · ${consumedCapacity.toFixed(1)} RCU.`
        : 'Preparando la tabla…';
      if (cursor) await pauseBetweenScans();
    } while (cursor);
    if (loadId === tableLoadId) {
      renderItems({tableName, items, consumedCapacity});
    }
  } catch (error) {
    if (loadId === tableLoadId) showError(itemsElement, error);
  }
}

async function refreshTables() {
  try {
    const result = await requestJson('/api/tables');
    element('table-count').textContent = result.tables.length;
    tablesElement.replaceChildren();
    if (!result.tables.length) {
      tablesElement.textContent = 'No se encontraron tablas en esta región.';
      return;
    }
    for (const tableName of result.tables) {
      const option = document.createElement('button');
      option.className = 'table-choice';
      option.type = 'button';
      option.append(document.createTextNode(tableLabel(tableName)));
      const physicalName = document.createElement('small');
      physicalName.className = 'table-physical-name';
      physicalName.textContent = tableName;
      option.append(physicalName);
      option.addEventListener('click', () => loadTable(tableName));
      tablesElement.append(option);
    }
  } catch (error) {
    showError(tablesElement, error);
    status.dataset.error = 'true';
    status.textContent = error.message;
  }
}

function renderUsers(result) {
  usersElement.replaceChildren();
  element('user-count').textContent = result.hasMore ? `${result.users.length}+` : result.users.length;
  element('user-pagination-note').textContent = result.hasMore
    ? 'Se muestran los primeros 600 usuarios; la cuenta tiene más páginas.'
    : '';
  if (!result.users.length) {
    usersElement.textContent = 'Todavía no hay usuarios registrados en este User Pool.';
    return;
  }
  const rows = result.users.map(user => ({
    'Correo': user.email || '—',
    'Nombre': user.name || '—',
    'ID de usuario': user.id || '—',
    'Estado': `${user.status}${user.enabled ? '' : ' · deshabilitado'}`,
    'Verificación de correo': user.emailVerified ? 'Verificado' : 'No verificado',
    'Fecha de registro': user.createdAt
      ? new Date(user.createdAt).toLocaleString('es-PE')
      : 'No disponible',
  }));
  usersElement.append(createDataTable(
    ['Correo', 'Nombre', 'ID de usuario', 'Estado', 'Verificación de correo', 'Fecha de registro'],
    rows,
  ));
}

async function refreshUsers() {
  try {
    const result = await requestJson('/api/users');
    renderUsers(result);
    element('last-updated').textContent = new Date().toLocaleTimeString('es-PE');
    status.dataset.error = 'false';
    status.textContent = 'Conectado a AWS. La lista de usuarios se refresca cada 30 segundos.';
  } catch (error) {
    showError(usersElement, error);
    status.dataset.error = 'true';
    status.textContent = error.message;
  }
}

async function refreshAll() {
  const refreshes = [refreshTables(), refreshUsers()];
  if (selectedTableName) refreshes.push(loadTable(selectedTableName));
  await Promise.all(refreshes);
}

element('refresh-all').addEventListener('click', refreshAll);
tableMenuToggle.addEventListener('click', () => {
  showTableMenu(tableMenuToggle.getAttribute('aria-expanded') !== 'true');
});
refreshAll();
window.setInterval(() => {
  if (document.visibilityState === 'visible') refreshUsers();
}, 30_000);
