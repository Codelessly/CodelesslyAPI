# Schema 3 → 4: the migration over the corpus

106 documents migrated; 702 rewrites, 0 unconvertible values, 0 behaviour changes.

## Entries per step

| Step | Rewrites | Unconvertible | Behaviour changes | Documents |
|---|---|---|---|---|
| `hero.flight` | 10 | 0 | 0 | 4 |
| `patches.schema4` | 330 | 0 | 0 | 9 |
| `transform.fold` | 362 | 0 | 0 | 7 |

## Unconvertible values (kept as `legacy.<name>`)

None.

## Behaviour changes

None.

## Checks

- 106 documents in 1385 files (106 schema 3) migrated without throwing.
- Migrating each result again changed nothing; migrate → encode → decode → encode was a fixed point for every one.
- New validation errors against the schema-2 validator: 0.
- Encoded size of the schema-3 documents: 16021534 bytes before, 16026980 after (+0.03%).
