ADMIN_EMAILS = ENV['FTP_ADMIN_EMAILS']
SENDING_EMAIL_ADDRESS = ENV['FTP_SENDING_EMAIL_ADDRESS']
# Secrets
SECRET_KEY_BASE = ENV['FTP_SECRET_KEY_BASE'] || '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
DEVISE_SECRET_KEY = ENV['FTP_DEVISE_SECRET_KEY']
DEVISE_PEPPER = ENV['FTP_DEVISE_PEPPER']
DEVISE_STRETCHES = Integer(ENV.fetch('FTP_DEVISE_STRETCHES', '10'), 10)

SMTP_ENABLED = ENV.has_key? 'SMTP_HOST'
USE_PNG_LOGO = false
GUEST_DEED_COUNT = 3
GUEST_TRANSCRIPTION_ENABLED = false
FACEBOOK_PIXEL_ID = ''
MIXPANEL_ID = ''
GA_ACCOUNT = ''
CLARITY=''
#single sign on options below
ENABLE_GOOGLEOAUTH = false
GOOGLE_CLIENT_ID = ENV['GOOGLE_CLIENT_ID']
GOOGLE_CLIENT_SECRET = ENV['GOOGLE_CLIENT_SECRET']
ENABLE_SAML = false
#IDP_SSO_TARGET_URL = 'your.saml.url'
#IDP_SSO_TARGET_URL = 'https://capriza.github.io/samling/samling.html' #easy test for saml without a saml server
#the below isn't a reference to the cert file, but the actual cert.  See https://github.com/omniauth/omniauth-saml for other options, like fingerprint.
#the initializer/devise.rb file is where this is used, and if you want to use fingerprint rather than cert, you can modify that file
IDP_CERT = ENV['IDP_CERT'] 

# ReCAPTCHA Settings
RECAPTCHA_SITE_KEY = ENV['RECAPTCHA_SITE_KEY']
RECAPTCHA_SECRET_KEY = ENV['RECAPTCHA_SECRET_KEY']

BENTO_ENABLED = false
BENTO_ACCESS_TOKEN = ENV['BENTO_ACCESS_TOKEN']

# Nice Levels for Rake Import. See `nice_rake.rb`
NICE_RAKE_ENABLED = true
NICE_RAKE_LEVEL = 10 # Values values -20 to 19 (only root can set less than 0)

ENABLE_OPENAI = false
OPENAI_ACCESS_TOKEN=ENV['OPENAI_ACCESS_TOKEN']

ENABLE_TRANSKRIBUS=false
TRANSKRIBUS_ACCESS_TOKEN=ENV['TRANSKRIBUS_ACCESS_TOKEN']

GCV_ENABLED = false
GCV_CREDENTIAL_FILE='/home/benwbrum/dev/products/fromthepage/integration/gcv/fromthepage-e2932d0557ba.json'
OCR_TRANSFORM_COMMAND='docker run --rm -i ubma/ocr-fileformat ocr-transform gcv hocr | docker run --rm -i ubma/ocr-fileformat ocr-transform hocr alto4.0'

# Elasticsearch settings
ELASTIC_ENABLED = ENV['ELASTIC_ENABLED'] && ENV['ELASTIC_ENABLED'].downcase == 'true' 
ELASTIC_CLOUD_ID = ENV['ELASTIC_CLOUD_ID']
ELASTIC_API_KEY = ENV['ELASTIC_API_KEY']
ELASTIC_SUFFIX = ENV['ELASTIC_SUFFIX']
