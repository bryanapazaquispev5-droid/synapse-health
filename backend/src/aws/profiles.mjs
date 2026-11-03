import {mutate} from './store.mjs';
import {invalid, object} from './validation.mjs';
const careersToEnglish = new Map([
  ['Medicina Humana', 'General Medicine'], ['Enfermería', 'Nursing'], ['Odontología', 'Dentistry'],
  ['Farmacia y Bioquímica', 'Pharmacy and Biochemistry'], ['Obstetricia', 'Obstetrics'],
  ['Nutrición', 'Nutrition'], ['Fisioterapia', 'Physical Therapy'],
]);
const englishGender = value => ({Hombre: 'Male', Mujer: 'Female', Male: 'Male', Female: 'Female'})[value];
const displayProfile = profile => ({...profile,
  ...(profile.gender ? {gender: englishGender(profile.gender) ?? profile.gender} : {}),
  ...(profile.career ? {career: careersToEnglish.get(profile.career) ?? profile.career} : {}),
});
export function profileFields(input) {
  // El perfil de DynamoDB solo acepta datos de perfil; las contraseñas las administra Cognito.
  object(input, ['name', 'career', 'gender']);
  const result = {};
  for (const [key, value] of Object.entries(input)) {
    if (typeof value !== 'string' || value.trim().length > 100 || !value.trim() ||
        (key === 'gender' && !englishGender(value))) throw invalid();
    const normalized = value.trim();
    result[key] = key === 'gender' ? englishGender(normalized)
      : key === 'career' ? careersToEnglish.get(normalized) ?? normalized : normalized;
  }
  return result;
}
export function createProfiles(store, now = () => new Date().toISOString()) {
  return {
    // Lee el perfil asociado al sub del usuario autenticado.
    async get(identity) { return displayProfile((await store.get(`USER#${identity.sub}`, 'PROFILE'))?.data ?? {}); },
    // Crea el perfil si no existe o actualiza sus campos permitidos si ya existe.
    async save(identity, input) {
      const patch = profileFields(input);
      const record = await mutate(store, `USER#${identity.sub}`, 'PROFILE', current => {
        const previous = current?.data;
        if (!previous && (!patch.name || !patch.career)) throw invalid('Provide name and career to complete your profile.');
        const createdAt = previous?.createdAt ?? now();
        return {data: {...previous, ...patch, uid: identity.sub, email: identity.email ?? '',
          authProvider: identity.provider ?? 'password', studyStreakDays: previous?.studyStreakDays ?? 0,
          createdAt, updatedAt: now(), ...(identity.photoUrl ? {photoUrl: identity.photoUrl} : {})}};
      });
      return displayProfile(record.data);
    },
  };
}
