const aws = require('aws-sdk');

const ses = new aws.SES({region: "us-west-1"});

exports.handler = async(event) => {
  const message = JSON.stringify(event);

  const emailConfig = {
    Source: process.env.TO_EMAIL,
    Destination: {
        ToAddresses: [process.env.TO_EMAIL],
    },
    Message: {
        Subject: {
            Data: 'Push notification',
            Charset: 'UTF-8',
        },
        Body: {
            Text: {
                Data: `New push in the repository:\n\n${message}`,
                Charset: 'UTF-8',
            },
        },
    }
  };

  try{
    await ses.sendEmail(emailConfig).promise();
    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'Function executed successfully!' }),
    };
  }catch(err){
    console.error(err);
  }
};
