# terraform-aws-emr

![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.12.0-blue.svg)
[![MIT License](https://badges.frapsoft.com/os/mit/mit.svg?v=102)](https://github.com/ellerbrock/open-source-badge/)

A Terraform module to create an [Amazon Elastic MapReduce (EMR) Cluster](https://aws.amazon.com/emr/).

## What Is Amazon EMR?
Amazon EMR is a managed cluster platform that simplifies running big data frameworks, such as Apache Hadoop and Apache
Spark, on AWS to process and analyze vast amounts of data. By using these frameworks and related open-source projects,
such as Apache Hive and Apache Pig, you can process data for analytics purposes and business intelligence workloads.
Additionally, you can use Amazon EMR to transform and move large amounts of data into and out of other AWS data stores
and databases, such as Amazon Simple Storage Service (Amazon S3) and Amazon DynamoDB.

## Tests

Tests are written using [Terratest](https://github.com/gruntwork-io/terratest). Please be aware that running the tests
will actually deploy real infrastructure and therefore it might produce costs.

```
go test -v -timeout 30m test/emr_cluster_test.go
```

## To-Do's
- [ ] Implement an example to run an EMR Cluster in a private network
- [ ] Add more tests
- [ ] At-Rest Encryption
- [ ] In-Flight Encryption
- [ ] Auditing
- [ ] Extend Documentation
