import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const directory = path.dirname(fileURLToPath(import.meta.url));
const pythonSource = fs.readFileSync(path.join(directory, 'build_public_health.py'), 'utf8');
const start = pythonSource.indexOf('TOPICS = ') + 'TOPICS = '.length;
const end = pythonSource.indexOf('\n\ndef make_note', start);
const source = pythonSource.slice(start, end);
let converted = '';
let quote = null;
let escaped = false;
for (const character of source) {
  if (quote) {
    converted += character;
    if (escaped) escaped = false;
    else if (character === '\\') escaped = true;
    else if (character === quote) quote = null;
  } else if (character === '"' || character === "'") {
    quote = character;
    converted += character;
  } else if (character === '(') converted += '[';
  else if (character === ')') converted += ']';
  else converted += character;
}
const topics = Function(`return (${converted});`)();
const area = {kind:'area', id:'public_health_epidemiology', name:'Public Health and Epidemiology', code:'PUBLIC_HEALTH', description:'Population health, epidemiologic methods, prevention, and community-level interventions.', order:10};

function makeNote(topicId, order, title, summary, sections, keyPoints, mnemonic) {
  const contentMarkdown = Array.isArray(sections)
    ? sections.map(([heading, text]) => `### ${heading}\n${text}`).join('\n\n')
    : `### Focus\n${sections}\n\n### Key points\n${keyPoints.map(point=>`- ${point}`).join('\n')}`;
  return {
    id:`${topicId}_note_${order}`, title, summary,
    contentMarkdown,
    keyPoints, mnemonics:[mnemonic], order, readMinutes:3, isPremium:false, sourceBook:'None'
  };
}

const noteContent={
 public_health_foundations:[
  ['Population lens','Public health functions','Population health asks how outcomes are distributed across groups and what shared conditions shape them. It complements clinical care by emphasizing prevention, protection, and organized community action.',['Public health works at population scale.','Clinical and public-health actions complement each other.','Distribution matters alongside averages.'],'See the pattern; improve the conditions.'],
  ['Prevention levels','Match action to disease stage','Primordial prevention prevents risk conditions from becoming common; primary prevents disease, secondary detects it early, and tertiary reduces consequences of established disease. A single program may include more than one level.',['Primordial changes upstream conditions.','Primary prevents onset; secondary detects early disease.','Tertiary limits complications and disability.'],'Before risk, before disease, early disease, established disease.'],
  ['Core public-health work','From evidence to action','Assessment describes needs and threats; policy development turns evidence into collective choices; assurance supports access, quality, and accountability. Community participation strengthens each step.',['Assess population needs and assets.','Develop policy with evidence and public input.','Assure fair access and evaluate results.'],'Assess, decide, assure.']],
 epidemiologic_measures:[
  ['Incidence and prevalence','New cases versus existing burden','Incidence counts new events in a population at risk over time. Prevalence counts all existing cases at a point or period and is influenced by both incidence and duration.',['Incidence requires new cases and an at-risk denominator.','Prevalence describes existing disease burden.','Longer survival can increase prevalence without increasing incidence.'],'Incidence enters; prevalence is present.'],
  ['Rates and risks','Choose the correct denominator','Cumulative incidence is the proportion becoming cases during a stated interval. An incidence rate divides new events by person-time, which handles different follow-up lengths. Always name the population and period.',['Risk needs a defined interval.','Rate uses accumulated person-time.','Do not compare raw counts from different population sizes.'],'Risk counts people; rate counts time.'],
  ['Association measures','Relative and absolute change','A risk ratio compares risks between groups; a risk difference subtracts them. Ratios show proportional contrast, while differences help estimate the extra burden associated with exposure. Neither alone proves causation.',['Risk ratio = exposed risk / comparison risk.','Risk difference = exposed risk − comparison risk.','Interpret estimates with design and uncertainty.'],'Ratio compares; difference subtracts.']],
 study_designs_causality:[
  ['Choosing a design','Start with the research question','Cohorts follow exposure groups for outcomes; case-control studies sample by outcome and compare prior exposure; cross-sectional studies measure exposure and outcome together. Trials assign an intervention, often randomly.',['Cohort begins with exposure.','Case-control begins with outcome.','Cross-sectional measures a snapshot.'],'Ask what was selected first.'],
  ['Bias and confounding','Identify alternative explanations','Confounding occurs when a third factor is related to exposure and outcome without being an intermediate step. Selection, recall, measurement, and attrition biases arise through different mechanisms and need design-specific safeguards.',['Confounders can distort group comparisons.','Differential recall can change reported past exposure.','Loss related to outcome can bias observed follow-up.'],'Check who entered, what was measured, and what differed.'],
  ['Causal reasoning','Association is one part of evidence','Temporality is necessary for causation, but an observed association can also reflect bias, confounding, or chance. Strength, consistency, dose-response, mechanism, and intervention evidence contribute to a broader judgment.',['Exposure must precede the outcome.','A p-value does not establish causation.','Evaluate alternative explanations and external validity.'],'Sequence first; alternatives next.']],
 screening_test_performance:[
  ['Test accuracy','Sensitivity and specificity','Sensitivity is the fraction of people with disease who test positive; specificity is the fraction without disease who test negative. Their denominators are different, so do not swap them.',['Sensitivity = true positives / all with disease.','Specificity = true negatives / all without disease.','False-negative and false-positive rates are their complements.'],'Start with disease status, then read the result.'],
  ['Predictive values','Prevalence changes interpretation','Positive predictive value is the chance of disease among positive results; negative predictive value is the chance of no disease among negative results. Both depend on prevalence in the tested group.',['PPV uses all positive results as denominator.','NPV uses all negative results as denominator.','Lower prevalence usually lowers PPV when accuracy is fixed.'],'Predictive value starts with the test result.'],
  ['Screening decisions','Net benefit, not detection alone','A screening program needs a meaningful early intervention, acceptable test performance, follow-up capacity, and a favorable balance of benefit and harm. False positives, overdiagnosis, and unequal access must be considered.',['A positive screen usually needs confirmation.','Overdiagnosis can lead to unnecessary treatment.','Access to follow-up is part of program effectiveness.'],'Screen, confirm, treat, evaluate.']],
 surveillance_outbreaks:[
  ['Surveillance basics','Data should lead to action','Public-health surveillance systematically collects, analyzes, interprets, and shares health information. Useful systems are timely, sufficiently complete, and linked to a decision or response.',['Define the public-health purpose.','Check completeness and timeliness.','Use findings to guide and evaluate action.'],'Collect, interpret, act.'],
  ['Outbreak investigation','Build a consistent case picture','A case definition applies uniform person, place, time, and clinical or laboratory criteria. A line list helps describe cases and identify patterns; criteria may be refined as evidence changes.',['Use consistent criteria to count cases.','Describe cases by person, place, and time.','Record changes in definitions.'],'Define, list, describe.'],
  ['Testing hypotheses','Combine several evidence streams','An epidemic curve and exposure comparisons can suggest a source, but laboratory, environmental, and epidemiologic findings should be interpreted together. A positive sample alone may not establish the pathway to illness.',['Compare risks among exposed and unexposed.','Match sampling to time and place of exposure.','Communicate uncertainty and protective steps.'],'Pattern plus comparison plus confirmation.']],
 prevention_immunization:[
  ['Immunization programs','Coverage and protection','Coverage is the share of eligible people who received a vaccine. It should be examined by subgroup and geography because a high overall value can hide communities with low access.',['State the eligible denominator.','Disaggregate coverage to find gaps.','Protection varies by vaccine and outcome.'],'Count eligible, count reached, find gaps.'],
  ['Community prevention','Make the healthy choice accessible','Programs work better when delivery fits local circumstances. Convenience, trusted messengers, language access, reminders, and community partnerships can reduce barriers, but implementation should be monitored.',['Identify the actual barrier before choosing a fix.','Combine communication with accessible services.','Measure reach and outcomes, not activity alone.'],'Find the barrier; fit the delivery.'],
  ['Evaluating interventions','Track reach, effect, and equity','Process measures show whether an intervention was delivered; outcome measures show changes in health or behavior. Pre-post changes need cautious interpretation because other events may explain them.',['Separate outputs from outcomes.','Compare results with a relevant baseline or group.','Check benefits and harms across subgroups.'],'Delivered is not the same as effective.']],
 social_determinants_equity:[
  ['Social determinants','Conditions shape opportunity','Income, housing, education, work, transportation, safety, and social connection influence exposure and access to resources. These factors operate alongside biology and individual behavior.',['Consider structural and material conditions.','Do not attribute group differences to biology without evidence.','Assess modifiable barriers.'],'Health reflects choices and the conditions around them.'],
  ['Equity analysis','Look beyond the average','Disaggregating outcomes by place or social group can reveal gaps hidden by a population mean. Equity means addressing avoidable, unfair barriers, not assuming every person needs identical support.',['Averages can hide unequal effects.','Use accessible, respectful data collection.','Protect privacy when reporting small groups.'],'Break down the average to find who is missed.'],
  ['Community partnership','Design with affected people','Residents can identify barriers that administrative data miss and help define acceptable outcomes. Co-design should include diverse voices and a clear process for acting on feedback.',['Use trusted local partnerships.','Ask communities what success means.','Check who is absent from participation.'],'Listen, co-design, report back.']],
 environmental_occupational_health:[
  ['Exposure assessment','Link hazard, route, and timing','Assessment asks what hazard was present, how people contacted it, how much and for how long, and when symptoms began. Environmental measurements are most useful when sampling matches tasks and conditions.',['Record substance, route, dose, duration, and time.','Compare affected and unaffected groups.','A measurement may miss short exposure peaks.'],'Hazard, route, dose, time.'],
  ['Hierarchy of controls','Prefer controlling the source','Elimination and substitution remove or replace hazards; engineering controls isolate or capture them; administrative measures change work practices; PPE protects the individual when other controls are insufficient.',['Control hazards as high in the hierarchy as feasible.','Verify engineering controls work.','Select PPE for the specific hazard and task.'],'Remove, replace, engineer, organize, protect.'],
  ['Environmental response','Reduce exposure and communicate','When a community exposure is plausible, reduce or control the source, assess who may be affected, and share practical guidance. A reading below a benchmark is not a guarantee of zero risk under every condition.',['Match monitoring to the reported event.','Protect people while evidence is gathered.','Explain what is known and uncertain.'],'Control exposure; explain evidence.']]
};

function notesFor(topicId) {
  return noteContent[topicId].map(([title,summary,sections,keyPoints,mnemonic],index)=>
    makeNote(topicId,index+1,title,summary,sections,keyPoints,mnemonic));
}

const rows=[area];
for (const [topicId,title,description,entries] of topics) {
  const quizzes=entries.map(([question,correct,distractors,rationale],index)=>{
    const correctIndex=(index*3+3)%4;
    const options=[...distractors];
    options.splice(correctIndex,0,correct);
    return {id:`${topicId}_q${String(index+1).padStart(2,'0')}`,order:index+1,question,options,correctIndex,rationale,type:'single_choice',sourceBook:'None',matchingPairs:[],orderingItems:[]};
  });
  rows.push({kind:'topic',id:topicId,title,description,order:rows.length,areaId:area.id,quizzesCount:quizzes.length,studyNotesCount:3,quizzes,studyNotes:notesFor(topicId),cheatsheetsCount:3,isAvailable:true});
}
if (topics.length!==8 || topics.some(topic=>topic[3].length!==20)) throw new Error(`Expected eight topics and twenty quizzes per topic; got ${topics.length}: ${topics.map(topic=>topic[3].length).join(',')}`);
fs.writeFileSync(path.join(directory,'public_health_epidemiology.jsonl'),rows.map(row=>JSON.stringify(row)).join('\n')+'\n');
console.log(`${topics.length} topics; ${topics.reduce((n,t)=>n+t[3].length,0)} quizzes; ${topics.length*3} notes`);
