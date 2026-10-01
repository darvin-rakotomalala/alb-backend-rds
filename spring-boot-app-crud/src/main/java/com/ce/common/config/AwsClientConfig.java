package com.ce.common.config;

import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.sts.StsClient;

import org.springframework.context.annotation.Bean;

@Configuration
public class AwsClientConfig {

    @Bean
    public StsClient stsClient() {
        return StsClient.builder()
                .region(Region.US_EAST_1)
                .build();
    }

}
