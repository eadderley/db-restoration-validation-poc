# db-restoration-validation-poc
automation for testing database restores for DR testing

> [!NOTE] 
> This repo is a POC. The modules should be broken out into proper module repos for real use and versioning. 

This repository is a demonstrator of how you can use Terraform to automatically demonstrate the availability and reliability of backups. 

It restores a database as closely as possible to the running database, from a snapshot of your choosing. Then, using credentials sourced from Secrets Managers, it runs a provided SQL script against the database to test the data integrity according to whatever parameters you provide in the script. Finally, it tears everything down and deletes the terraform state.

The processes are designed to be run in CI, but can be run locally. Because the CI container is wholly ephemeral, secrets and state are not insecurely persisted. The only thing that remains in CI is the output of the run. 

Note that some databases will take some time to restore, a process that is then extended by the queries you place in your SQL script. However, the advantage of this repo's design is that all of this happens without your input, so you can check back in at your leisure.  

# How to use this repo
## Required info
You need the following information:
- Identifier of the source DB
- snapshot identifier that you are restoring from
-- in AWS this is available via the UI or CLI
-- in GCP this is only available via the CLI with `gcloud sql backups list -i $databaseName` - GCP only accepts the Backup Run ID 
- a password in secret manager that can read from that DB
-- for now, this must simply be the password of the database, not, for example, a connection string as some teams store by default
- a SQL script that can be run against both 
-- ideally, this script produces comparable, if not identical output against both
-- you should familiarize yourself with what remote scripts will display when run to have digestible, analyzable output in the CI run. 

## CI Setup
> [!NOTE] 
> Forthcoming

## Rough Directions
1. Check out repo and make a new branch
2. Update values in main.tf
3. Provide your SQL script in the `scripts/` directory
4. Commit your changes to your branch
5. Check your CI for the output