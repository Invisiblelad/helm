from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Welcome Folks! It is a sample Devops Project '

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')

