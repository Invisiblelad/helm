from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Welcome Folks! It's a Spinnaker  Project '

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')

