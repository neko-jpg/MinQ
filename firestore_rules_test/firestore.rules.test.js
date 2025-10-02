const { assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { initializeTestEnvironment, RulesTestEnvironment } = require('@firebase/rules-unit-testing');
const fs = require('fs');

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'minq-test',
    firestore: {
      rules: fs.readFileSync('firestore.rules', 'utf8'),
      host: 'localhost',
      port: 8080,
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

describe('Firestore Rules Tests', () => {
  describe('Users Collection', () => {
    test('ユーザーは自分のプロフィールを読み取れる', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('users').doc('alice').set({
          uid: 'alice',
          displayName: 'Alice',
          createdAt: new Date(),
        });
      });

      await assertSucceeds(
        alice.firestore().collection('users').doc('alice').get()
      );
    });

    test('ユーザーは他人のプロフィールを読み取れない', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('users').doc('bob').set({
          uid: 'bob',
          displayName: 'Bob',
          createdAt: new Date(),
        });
      });

      await assertFails(
        alice.firestore().collection('users').doc('bob').get()
      );
    });

    test('ユーザーは自分のプロフィールを更新できる', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('users').doc('alice').set({
          uid: 'alice',
          displayName: 'Alice',
          createdAt: new Date(),
        });
      });

      await assertSucceeds(
        alice.firestore().collection('users').doc('alice').update({
          displayName: 'Alice Updated',
        })
      );
    });

    test('未認証ユーザーはプロフィールを読み取れない', async () => {
      const unauthed = testEnv.unauthenticatedContext();
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('users').doc('alice').set({
          uid: 'alice',
          displayName: 'Alice',
          createdAt: new Date(),
        });
      });

      await assertFails(
        unauthed.firestore().collection('users').doc('alice').get()
      );
    });
  });

  describe('Quests Collection', () => {
    test('ユーザーは自分のクエストを作成できる', async () => {
      const alice = testEnv.authenticatedContext('alice');

      await assertSucceeds(
        alice.firestore().collection('quests').add({
          userId: 'alice',
          title: 'Test Quest',
          createdAt: new Date(),
        })
      );
    });

    test('ユーザーは自分のクエストを読み取れる', async () => {
      const alice = testEnv.authenticatedContext('alice');
      let questId;

      await testEnv.withSecurityRulesDisabled(async (context) => {
        const docRef = await context.firestore().collection('quests').add({
          userId: 'alice',
          title: 'Test Quest',
          createdAt: new Date(),
        });
        questId = docRef.id;
      });

      await assertSucceeds(
        alice.firestore().collection('quests').doc(questId).get()
      );
    });

    test('ユーザーは他人のクエストを読み取れない', async () => {
      const alice = testEnv.authenticatedContext('alice');
      let questId;

      await testEnv.withSecurityRulesDisabled(async (context) => {
        const docRef = await context.firestore().collection('quests').add({
          userId: 'bob',
          title: 'Bob Quest',
          createdAt: new Date(),
        });
        questId = docRef.id;
      });

      await assertFails(
        alice.firestore().collection('quests').doc(questId).get()
      );
    });

    test('ユーザーは自分のクエストを更新できる', async () => {
      const alice = testEnv.authenticatedContext('alice');
      let questId;

      await testEnv.withSecurityRulesDisabled(async (context) => {
        const docRef = await context.firestore().collection('quests').add({
          userId: 'alice',
          title: 'Test Quest',
          createdAt: new Date(),
        });
        questId = docRef.id;
      });

      await assertSucceeds(
        alice.firestore().collection('quests').doc(questId).update({
          title: 'Updated Quest',
        })
      );
    });

    test('ユーザーは自分のクエストを削除できる', async () => {
      const alice = testEnv.authenticatedContext('alice');
      let questId;

      await testEnv.withSecurityRulesDisabled(async (context) => {
        const docRef = await context.firestore().collection('quests').add({
          userId: 'alice',
          title: 'Test Quest',
          createdAt: new Date(),
        });
        questId = docRef.id;
      });

      await assertSucceeds(
        alice.firestore().collection('quests').doc(questId).delete()
      );
    });
  });

  describe('Quest Logs Collection', () => {
    test('ユーザーは自分のログを作成できる', async () => {
      const alice = testEnv.authenticatedContext('alice');

      await assertSucceeds(
        alice.firestore().collection('questLogs').add({
          userId: 'alice',
          questId: 'quest123',
          completedAt: new Date(),
        })
      );
    });

    test('ユーザーは自分のログを読み取れる', async () => {
      const alice = testEnv.authenticatedContext('alice');
      let logId;

      await testEnv.withSecurityRulesDisabled(async (context) => {
        const docRef = await context.firestore().collection('questLogs').add({
          userId: 'alice',
          questId: 'quest123',
          completedAt: new Date(),
        });
        logId = docRef.id;
      });

      await assertSucceeds(
        alice.firestore().collection('questLogs').doc(logId).get()
      );
    });

    test('ユーザーは自分のログを削除できる', async () => {
      const alice = testEnv.authenticatedContext('alice');
      let logId;

      await testEnv.withSecurityRulesDisabled(async (context) => {
        const docRef = await context.firestore().collection('questLogs').add({
          userId: 'alice',
          questId: 'quest123',
          completedAt: new Date(),
        });
        logId = docRef.id;
      });

      await assertSucceeds(
        alice.firestore().collection('questLogs').doc(logId).delete()
      );
    });
  });

  describe('Pairs Collection', () => {
    test('ペアメンバーはペア情報を読み取れる', async () => {
      const alice = testEnv.authenticatedContext('alice');
      let pairId;

      await testEnv.withSecurityRulesDisabled(async (context) => {
        const docRef = await context.firestore().collection('pairs').add({
          members: ['alice', 'bob'],
          createdAt: new Date(),
        });
        pairId = docRef.id;
      });

      await assertSucceeds(
        alice.firestore().collection('pairs').doc(pairId).get()
      );
    });

    test('非メンバーはペア情報を読み取れない', async () => {
      const charlie = testEnv.authenticatedContext('charlie');
      let pairId;

      await testEnv.withSecurityRulesDisabled(async (context) => {
        const docRef = await context.firestore().collection('pairs').add({
          members: ['alice', 'bob'],
          createdAt: new Date(),
        });
        pairId = docRef.id;
      });

      await assertFails(
        charlie.firestore().collection('pairs').doc(pairId).get()
      );
    });
  });
});
