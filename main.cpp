/*
 This file is derived from aws examples 
 https://github.com/awsdocs/aws-doc-sdk-examples/blob/main/cpp/example_code/kinesis/put_get_records.cpp
*/

#include <chrono>
#include <ctime>
#include <iostream>
#include <memory>
#include <random>
#include <thread>

#include <aws/core/Aws.h>
#include <aws/core/Region.h>
#include <aws/core/client/ClientConfiguration.h>
#include <aws/core/utils/Outcome.h>
#include <aws/core/utils/UUID.h>
#include <aws/core/utils/logging/LogLevel.h>
#include <aws/core/utils/memory/stl/AWSStringStream.h>
#include <aws/core/utils/threading/Executor.h>
#include <aws/kinesis/KinesisClient.h>
#include <aws/kinesis/model/DescribeStreamRequest.h>
#include <aws/kinesis/model/DescribeStreamResult.h>
#include <aws/kinesis/model/GetRecordsRequest.h>
#include <aws/kinesis/model/GetRecordsResult.h>
#include <aws/kinesis/model/GetShardIteratorRequest.h>
#include <aws/kinesis/model/GetShardIteratorResult.h>
#include <aws/kinesis/model/PutRecordRequest.h>
#include <aws/kinesis/model/PutRecordResult.h>
#include <aws/kinesis/model/Shard.h>

std::string time_str(std::time_t tm = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now()))
{
    std::string str = ctime(&tm);
    if (!str.empty()) {
        str.pop_back();
    }
    return str;
}

/**
* Attempts to Puts record into a kinesis stream.
*
* This code expects that you have AWS credentials set up per:
* http://docs.aws.amazon.com/sdk-for-cpp/v1/developer-guide/credentials.html
*/
int main(int argc, char** argv)
{
    Aws::SDKOptions options;
    options.httpOptions.installSigPipeHandler = true;
    options.loggingOptions.logLevel = Aws::Utils::Logging::LogLevel::Debug;
    Aws::InitAPI(options);
    {
        Aws::Client::ClientConfiguration clientConfig;
        // set your region
        clientConfig.region = Aws::Region::AP_SOUTH_1;
        Aws::Kinesis::KinesisClient kinesisClient(clientConfig);
        clientConfig.executor = std::make_shared<Aws::Utils::Threading::PooledThreadExecutor>(1);

        int i = 1;

        while (1) {
            Aws::StringStream ss;
            ss << "data-" << (i % 1001);

            std::cout << "PutRecord: " << ss.str() << std::endl;

            if (i == 10001)
                i = 1;
            else
                i++;

            Aws::Utils::ByteBuffer bytes((unsigned char*)ss.str().c_str(), ss.str().length());
            auto request = Aws::Kinesis::Model::PutRecordRequest()
                               .WithStreamName("test-kinesis-openssl-1p0")
                               .WithPartitionKey(Aws::Utils::UUID::RandomUUID())
                               .WithData(Aws::Utils::ByteBuffer(bytes));

            kinesisClient.PutRecordAsync(request,
                [](const Aws::Kinesis::KinesisClient* /*client*/,
                    const Aws::Kinesis::Model::PutRecordRequest& /*request*/,
                    const Aws::Kinesis::Model::PutRecordOutcome& outcome,
                    const std::shared_ptr<const Aws::Client::AsyncCallerContext>& /*ctx*/) {
                    if (outcome.IsSuccess()) {
                        std::cout << "Record Put success\n"
                                  << "\tshardId: " << outcome.GetResult().GetShardId() << std::endl
                                  << "\thashKey: " << outcome.GetResult().GetSequenceNumber() << std::endl;
                    } else {
                        std::cout << "PutRecord failed: " << outcome.GetError().GetMessage();
                        const auto& err = outcome.GetError();

                        std::cout << "KinesisError: " << err.GetExceptionName() << std::endl;
                        std::cout << "PutRecord failed: " << outcome.GetError().GetMessage() << std::endl;
                    }
                });
            std::cout << "sleep @ " << time_str() << "\n";
            std::this_thread::sleep_for(std::chrono::seconds(30));
        }
    }
    Aws::ShutdownAPI(options);

    return 0;
}
