package main

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"regexp"
	"testing"
)

func TestS3Creation(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./unit-test",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	functionName := terraform.Output(t, terraformOptions, "function_name")
	resultCode := terraform.Output(t, terraformOptions, "result_code")

	assert.Regexp(t, regexp.MustCompile(`^instance-scheduler-lambda-function*`), functionName)
	assert.Regexp(t, regexp.MustCompile(`^200*`), resultCode)
}
