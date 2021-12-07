# Hello MPI!

This quick start guide is intended to provide a quick start for users who wish to test-drive the SanteMPI project. 

**NOTE:** This tutorial is intended as a beginner level introduction to get users up and running with the SanteMPI project. Developers of SanteMPI plugins or triggers will need additional tooling. Additionally, this tutorial should not be used for production environments.

## Pre-Requisites

This tutorial uses Docker as a basis for illustrating SanteMPI functions. In order to complete this tutorial, users should:

* Have Docker installed on the host system (on Windows or Linux)
* Have a text editor which can be used to edit the docker YML files

## Create the Docker Application

In a text editor, create a new directory and create a new text file called `docker-compose.yml` in that directory.

```
mkdir quickstart
notepad docker-compose.yml
```

First, you will need to create a postgresql service, this is where the SanteMPI database will be stored.

```yaml
version: "3.3"

services:
  db:
    image: postgres
    container_name: sdb-postgres
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: santedb
      POSTGRES_PASSWORD: SanteDB123
    restart: always

```

This section:

* Creates a new docker service called `db` from the `postgres:latest` tag
* Exposes the PostgreSQL database on the host on port 5432
* Sets the initial postgresql user to `santedb` with password `SanteDB123`

Next, declare the `santedb-mpi` service , this service will host the the actual iCDR which has SanteMPI:

```yaml
  santedb:
    image: santesuite/santedb-mpi:latest
    container_name: santedb-mpi
    environment:
      - SDB_FEATURE=LOG;DATA_POLICY;AUDIT_REPO;ADO;PUBSUB_ADO;RAMCACHE;SEC;SWAGGER;OPENID;FHIR;HL7;HDSI;AMI;BIS;MDM;MATCHING;IHE_PIXM;IHE_PDQM;IHE_PMIR;IHE_PIX;IHE_PDQ
      - SDB_HL7_AUTHENTICATION=Msh8
      - SDB_MATCHING_MODE=WEIGHTED
      - SDB_MDM_RESOURCE=Patient
      - SDB_MDM_AUTO_MERGE=false
      - SDB_DB_MAIN=server=sdb-postgres;port=5432; database=santedb; user id=santedb; password=SanteDB123; pooling=true; MinPoolSize=5; MaxPoolSize=15; Timeout=60;
      - SDB_DB_AUDIT=server=sdb-postgres;port=5432; database=auditdb; user id=santedb; password=SanteDB123; pooling=true; MinPoolSize=5; MaxPoolSize=15; Timeout=60;
      - SDB_DB_MAIN_PROVIDER=Npgsql
      - SDB_DB_AUDIT_PROVIDER=Npgsql
      - SDB_DATA_POLICY_ACTION=HIDE
      - SDB_DELAY_START=5000
    ports:
      - "8080:8080"
      - "2100:2100"
    depends_on:
      - db
    restart: always
```

This section of the file:

* Creates a service named `santedb-mpi` in the docker environment
* Enables feature via the `SDB_FEATURE` environment variable (for reference see: [feature-configuration.md](https://help.santesuite.org/installation/installation/santedb-server/installation-using-appliances/docker-containers/feature-configuration)
* Instructs the iCDR to enable [master-data-storage.md](https://help.santesuite.org/santedb/data-storage-patterns/master-data-storage) for `Patient` resources
* Connects the main database to `santedb` on the `db` container.
* Connects the audit database to `auditdb` on the db container
* Instructs the iCDR to `hide` any data which is tagged with a privacy policy (other options are `redact`, `audit, none`
* Instructs the iCDR to wait 5 seconds before starting (to allow the database to initialize)
* Forward/expose the iCDR APIs on port 8080

Finally, create a container which will run the web access gateway using `santedb-www:latest`

```yaml
  www:
    image: santesuite/santedb-www:latest
    container_name: santedb-www
    ports:
      - "9200:9200"
    depends_on:
      - santedb
    restart: alwaysyaml
```

This section:

* Creates a service named `www` which uses the `santedb-www` image
* Forward traffic to the web portal on port 9200

## Start the Docker Application

After saving the text file, return to your command prompt and type:

```
docker compose -f docker-compose.yml up
```

This will start the SanteDB iCDR (running SanteMPI), the web access gateway and database. Initial startup of the SanteMPI container can take upwards of 5 minutes. You will see a log entry which indicates that startup was successful after this time.

## Complete the Tutorial

This readme is intended to provide a quick-start for using the files in this repository. The complete Quick-Start tutorial can be found on the [SanteDB Wiki - Quick Start](https://help.santesuite.org/installation/quick-start-guide)