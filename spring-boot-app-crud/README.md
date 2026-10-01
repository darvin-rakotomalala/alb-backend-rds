## CRUD Spring Boot Application

In this project, I will show how to perform CRUD operations with REST endpoints on an PostgreSQL table from a Spring
Boot application.

### Pre-requisites

***

* Java 17
* Spring Boot 4
* Spring Data JPA
* AWS SDK and AWS Spring Cloud
* Spring Initializr
* Maven 3+
* Lombok
* PostgreSQL
* MapStruct
* AWS account with resource access

### Architecture overview

***

<img src="Spring_Boot_Architecture.png" alt="Spring Boot Architecture" width="350">

### Implementation

***

* Step 1: **Add the Dependencies**

### Run & Test application

***

* Run application `mvn spring-boot:run`
* Health Check: ```GET http://localhost:8080/health```
* Create Note: ```POST http://localhost:8080/notes```
* Create multi Note: ```POST http://localhost:8080/notes/save-all```
* Get All Note and/or filter by title: ```GET http://localhost:8080/notes```
* Get Note by ID: ```GET http://localhost:8080/notes/{id}```
* Update Note: ```PUT http://localhost:8080/notes```
* Delete Note: ```DELETE http://localhost:8080/notes/{id}```

**Swagger URL** - ```http://localhost:8080/v3/api-docs``` and/or ```http://localhost:8080/swagger-ui/index.html```

### Benefits of Spring Boot and AWS Integration

***

By combining Spring Boot with AWS, developers can enjoy several benefits:

- **Rapid Development**: Spring Boot’s convention-over-configuration approach allows developers to quickly build and
  iterate on their applications.
- **Scalability**: AWS provides automatic scaling capabilities that allow applications to handle increased traffic and
  demand without manual intervention.
- **Reliability**: AWS offers high availability and fault tolerance, ensuring that applications remain accessible and
  performant.
- **Security**: AWS provides robust security features, including encryption, access control, and compliance
  certifications, to protect sensitive data and applications.

### Summary

***

We have successfully:

* Created a complete Spring Boot CRUD application with REST endpoints
* Configured the application with database properties
* Built the application into a deployable JAR file
* Tested all CRUD operations
