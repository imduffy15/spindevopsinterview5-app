# Spin Devops Interview 5 App

[![Build Status](https://woodpecker.chllng.ianduffy.ie/api/badges/imduffy15/spindevopsinterview5-app/status.svg
)](https://woodpecker.chllng.ianduffy.ie/imduffy15/spindevopsinterview5-app)

## Plan

This repository will contain the notejam application implemented with Spring/Java and all relevant files to deploy the application.

## Usage

The application is automatically build on a push by https://woodpecker.chllng.ianduffy.ie/ (SSO with your spin.pm gsuite + github login required). The `.drone.yml` defines what should occur, its essentially  just a `docker build .` followed by a `docker push` to a private ECR. The logic is standardised within a drone plugin  so it can be used across projects easily https://github.com/imduffy15/woodpecker-docker-plugin

All build steps are contained within the Dockerfile so developers can easily validate a successful build locally with `docker build .`. In addition to this, docker layers are used to optimise the build process as much as possible; dependencies are not refetched unless pom.xml changes.

## Services

### Database

An external database provided by AWS RDS is used. This is provisioned automatically by the devops team and credentials are provided. These credentials are stored within  this repository encrypted with a KMS key.

### SES

For the password reset feature an SMTP server is required. This has been configured with AWS SES. The SES key is provisioned automatically by the devops team and credentials are provided. These are stored within this repository encrypted with a KMS key.

** Note: ** the provided AWS account is still in  the SES sandbox, as a result emails cannot be sent to unvalidated emails, for verification purposes I manually verified `notejam@ianduffy.ie`, feel free to register your own email for test purposes.

## Deployment

Once a build is completed it can be deployed, the deployment occurs with helmfile via the woodpecker environment. Sadly there is no web ui for it and it requires the woodpecker UI. The logic for the deployment is standardised within a drone plugin so it can be used across projects easily https://github.com/imduffy15/woodpecker-helm-plugin

Instructions for configuring the woodpecker CLI can be found at https://woodpecker.chllng.ianduffy.ie/account/token the CLI can be found at https://github.com/laszlocph/woodpecker/releases

Once installed, deployments can be executed as follows:

```
$ drone deploy owner/repo build_id [blue|green]
```

For example:

```
$ drone deploy owner/repo 49 green
```

would deploy the green environment which is available at any of the following ingresses:

 - https://green-notejam.chllng.ianduffy.ie
 - https://green-www.chllng.ianduffy.ie
 - https://green.chllng.ianduffy.ie

Once you've validated you are happy with the deployment you can promote it to be behind the main entrypoint:

```
$ drone deploy owner/repo 49 green --param entrypoint=true
```

This will make the deployment available on the customer facing ingresses:

  - chllng.ianduffy.ie
  - notejam.chllng.ianduffy.ie
  - www.chllng.ianduffy.ie

The page will show a ribbon in the top left corner of the page to identify the live color.

The old environment (assumed blue) can safely be destroyed:

```
$ drone deploy owner/repo 49 blue --param destroy=true
```

## Monitoring

The application is exposed via nginx ingress. Nginx ingress metrics are scraped by prometheus and available via grafana

This is viewable (SSO via your spin.pm gsuite account) at https://grafana.chllng.ianduffy.ie/d/nginx/nginx-ingress-controller
