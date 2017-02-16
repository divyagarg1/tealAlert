
from flask import Flask, request
 
from twilio.rest import TwilioRestClient
 
app = Flask(__name__)
 
# put your own credentials here 
ACCOUNT_SID = 'ACb8b4c02e3b6380fa9edc5aa5bf99560b' 
AUTH_TOKEN = '86b05a7c913ba27afe8dca77d025d275' 
 
client = TwilioRestClient(ACCOUNT_SID, AUTH_TOKEN)
 
@app.route('/sms', methods=['POST'])
def send_sms():
    print request.data
    message = client.messages.create(
        to=request.form['To'], 
        from_='+12565308422', 
        body=request.form['Body'],
    )
 
    return message.sid
 
if __name__ == '__main__':
        app.run(host="0.0.0.0",port=5000)
