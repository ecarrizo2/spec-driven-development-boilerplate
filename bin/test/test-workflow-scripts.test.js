const { slugify } = require('../workflow-scripts/_shared/config');
const { detectSddContext, getBranchNamingIssues, getBlastRadiusIssues } = require('../workflow-scripts/_shared/sdd');

describe('workflow script helpers');

it('slugify normalizes branch fragments', () => {
  assertEqual(slugify('Hello World!'), 'hello-world');
  assertEqual(slugify('plan/PROJ-1_add-stuff'), 'plan-proj-1-add-stuff');
});

it('detectSddContext identifies epic and execution branches', () => {
  const epic = detectSddContext('epic/PROJ-1_feature', '');
  assertEqual(epic.branchType, 'epic');
  assertEqual(epic.isSdd, true);

  const exec = detectSddContext('feat/PROJ-1_feature', '**Epic ID:** PROJ-1');
  assertEqual(exec.branchType, 'execution');
  assertEqual(exec.isSdd, true);
});

it('getBranchNamingIssues reports invalid names', () => {
  const result = getBranchNamingIssues('feat/bad-branch');
  assertEqual(result.branchType, 'execution');
  assert(result.issues.length > 0, 'should report issues');
});

it('getBlastRadiusIssues flags unexpected files', () => {
  const result = getBlastRadiusIssues({
    branchType: 'plan',
    changedPaths: ['src/app.js', 'epics/foo/task-graph.md'],
  });
  assert(result.findings.length > 0, 'should report findings');
});
