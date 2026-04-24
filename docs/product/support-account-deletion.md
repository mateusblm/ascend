# Support And Account Deletion

## Purpose

Define the minimum operational path for support and account/data deletion requests before broader distribution.

## Current Status

Ascend now has an in-app account surface that explains support, privacy, and deletion expectations.

The support contact is still a release-readiness dependency:

- current placeholder: `support@ascend.app`
- current app config key: `ASCEND_SUPPORT_EMAIL`
- required before external beta: replace placeholder with a real monitored inbox or support channel

## Minimum Support Scope

Before public beta, support must be able to answer:

- login/account access issues
- progression sync confusion
- competitive verification failures
- reward claim issues
- crash or release regressions reported by testers

## Account Deletion Direction

Until a self-serve deletion path exists, Ascend should support a manual deletion workflow:

1. confirm the identity of the requesting user
2. confirm the request scope
3. remove or disable authenticated access if required
4. review and delete remote user-linked records where policy requires it
5. confirm completion back to the user

## Remote Data Areas To Review

Deletion review should include user-linked remote collections such as:

- progression
- progression history
- promotion exam
- season rewards and season history
- season legacy/profile if policy requires full deletion
- integrity and integrity history
- competitive quest sessions and grants

## Public Release Requirement

Before public beta or store launch:

- replace the placeholder support channel
- publish the response expectation for support and deletion requests
- align the public privacy policy and terms with the actual operational process
