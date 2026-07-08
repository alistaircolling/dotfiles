We are going to release the feature on this branch. This task is to make a plan for that deployment.

Please can you:

- Review the code on the branch to understand what functionality is added (by diffing against main)
- List any environment variables that are used / added in this branch
- List any configuration that may be required on external services (e.g. adding production domain to a whitelist or some config in a 3rd party service added in this feature)
- List any other changes or actions that need to be taken to deploy this feature
- List any database changes added in this feature
- List any risks with this deployment and categorize by likelihood and impact
- Compile this information into a deployment plan with actions in the order that they should be taken
- Make a rollback plan (should this deployment fail / break something) including all actions required to restore the previous deployment of `main` (we will probably promote the previous main deployment then fix any issues then redeploy the fixed feature)
- Is there anything else we should consider for this deployment?

Please add all of this information into a markdown document.

Please take your time. If you require any clarification on anything just ask at any point.
