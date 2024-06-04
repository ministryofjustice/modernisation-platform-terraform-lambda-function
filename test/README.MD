# Terratest Unit Tests

## Initialisation

On first set up of a new repository, run:

```
go mod init github.com/ministryofjustice/<repo-name>
```

Then run:

```
go mod tidy
```

# How to run the tests locally

Run the tests from within the `test` directory using the `testing-ci` user credentials.

Get the credentials from secrets manager using the helper script in the modernisation-platform main repo.

```
cd modernisation-platform/scripts/internal/get-testing-ci-user-creds
aws-vault exec mod -- go run get_testing_creds.go
```

Copy the credentials from the output of the script and paste them into the terminal from which you will run the tests.

Next go into the testing folder and run the tests.

```
cd test
go mod download
go test -v
```

Upon successful run, you should see an output similar to the below

```
TestLambdaCreation 2024-05-24T16:05:07+01:00 logger.go:66: Destroy complete! Resources: 29 destroyed.
TestLambdaCreation 2024-05-24T16:05:07+01:00 logger.go:66:
--- PASS: TestLambdaCreation (509.19s)
PASS
ok  	github.com/ministryofjustice/modernisation-platform-terraform-lambda-function	 509.522s
```

## References

1. https://terratest.gruntwork.io/docs/getting-started/quick-start/
2. https://github.com/ministryofjustice/modernisation-platform-terraform-lambda-function/blob/main/.github/workflows/go-terratest.yml
