package com.ce;

import lombok.extern.slf4j.Slf4j;
import org.jspecify.annotations.NonNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import software.amazon.awssdk.services.sts.StsClient;
import software.amazon.awssdk.services.sts.model.GetCallerIdentityResponse;

@Slf4j
@SpringBootApplication
@EnableCaching
@EnableJpaAuditing
public class MainApplication implements ApplicationRunner {

    @Autowired
    private StsClient stsClient;

    public static void main(String[] args) {
        SpringApplication.run(MainApplication.class, args);
    }

    @Override
    public void run(@NonNull ApplicationArguments args) throws Exception {
        log.info("############################   RUN   ############################");

        try {
            GetCallerIdentityResponse identity = stsClient.getCallerIdentity();
            log.info("##### Account: {}", identity.account());
            log.info("##### ARN: {}", identity.arn());
            log.info("##### User ID: {}", identity.userId());
        } catch (Exception e) {
            log.error("Credentials invalid: {}", e.getMessage());
        }
    }
}
