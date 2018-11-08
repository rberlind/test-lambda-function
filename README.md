# Introduction
The Terraform code in this repository was written to test the Sentinel policy. It is not intended to actually deploy a working Lambda function. The actual Python code in app.zip would not work without an RDS MySQL database deployed. So, please do not try to actually use the Terraform code to provision the Lambda function. However, if you would like to provision the Lambda function and actually use it, please see my [LambdaFunctionWithMySQLAndVault](https://github.com/rberlind/LambdaFunctionWithMySQLAndVault) repository.

Note that the various txt files contain variations of main.tf that can be used to test the Sentinel policy after re-naming main.tf to have a txt extension and then changing the txt extension on one of the other files to tf.
