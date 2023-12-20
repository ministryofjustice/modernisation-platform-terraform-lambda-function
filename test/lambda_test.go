package main

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"regexp"
	"testing"
)

func TestLambdaCreation(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./unit-test",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	functionName := terraform.Output(t, terraformOptions, "function_name")
	resultCode := terraform.Output(t, terraformOptions, "result_code")
	
	subnetId := terraform.Output(t, terraformOptions, "subnet_ids")
	securityGroupId := terraform.Output(t, terraformOptions, "security_group_ids")
	
	re := regexp.MustCompile(`[{}\[\]\s]`)
	subnetId = re.ReplaceAllString(subnetId, "")
	securityGroupId = re.ReplaceAllString(securityGroupId, "")

	assert.Regexp(t, regexp.MustCompile(`^instance-scheduler-lambda-function*`), functionName)
	assert.Regexp(t, regexp.MustCompile(`^200*`), resultCode)
	
	assert.Regexp(t, regexp.MustCompile(`^subnet-\w+$`), subnetId)
	assert.Regexp(t, regexp.MustCompile(`^sg-\d+$`), securityGroupId)
}