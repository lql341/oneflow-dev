# Reports and measurement discipline

## Naming

```text
oneflow-<topic>-<document-type>[-YYYYMMDD].<ext>
```

- Use a stable name such as `current` for the actively maintained report.
- Use a date suffix for point-in-time snapshots and evidence.
- Keep Markdown as the source of truth; when a matching HTML exists, update
  both in the same change.
- Maintain a report index next to the reports.

## Content expectations

Every performance or validation report states:

1. the source revision and toolchain;
2. the exact benchmark parameters and resource tuple;
3. which comparison basis was used (`repeats`, steps, warmup);
4. correctness evidence that gates the performance claims;
5. known limits — what the numbers do **not** prove.

## Publication boundary

Suitable for a public repository: aggregate measurements, methodology,
resource tuples in neutral form, architecture notes and conclusions.

Keep out: raw CI or scheduler logs, credentials, personal account names,
private absolute paths, hostnames, job identifiers, and any cluster
configuration that is not already public. When in doubt, redact to a neutral
label and keep the evidence in a private artifact store.

## Errata

When a published number is found to be wrong:

- fix the maintained report and any derived summaries;
- keep an inline erratum note that names the old value, the cause and the
  corrected value;
- record the audit that found it in the point-in-time report.
