import config from "../../project.config";

import { NativeModules } from 'react-native';
var TokenSource = NativeModules.TokenSource;


export default class AuthService {
  async parseJSON(response) {
    return new Promise(resolve =>
      response.json().then(json =>
        resolve({
          status: response.status,
          ok: response.ok,
          json
        })
      )
    );
  }

  async register(name, email, password) {
    const data = {
      name: name,
      email: email,
      password: password
    };

    const requestBody = {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "x-requested-with": "XMLHttpRequest"
      },
      body: JSON.stringify(data)
    };

    return new Promise((resolve, reject) => {
      fetch(config.API_BASE_PATH + "/register", requestBody)
        .then(this.parseJSON)
        .then(response => {
          console.log(response)
          if (!response.ok) return reject(response.json);
          // this.setToken(response.json.access_token);
          return resolve(response.json);
        });
    });
  }

  async login(email, password) {
    const data = {
      email: email,
      password: password
    };

    const requestBody = {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "x-requested-with": "XMLHttpRequest"
      },
      body: JSON.stringify(data)
    };

    return new Promise((resolve, reject) => {
      fetch(config.API_BASE_PATH + "/login", requestBody)
        .then(this.parseJSON)
        .then(response => {
          console.log(response)
          if (!response.ok) return reject(response.json);
          this.setToken(response.json.access_token);
          return resolve(response.json);
        });
    });
  }

  async forgotPass(email) {
    const data = {
      email: email,
    };

    return new Promise((resolve, reject) => {
      fetch(config.API_BASE_PATH + `/forgot-password?email=${email}`, {method:"GET"})
        .then(response => {
          console.log(response)
          if (!response.ok) return reject(response.json);
          return resolve(response.json);
        });
    });
  }

  async setToken(token) {
    try {
      await TokenSource.set(token);
    } catch (error) {
      console.log(error);
      throw err;
    }
  }

  async getToken() {
    try {
      const token = await TokenSource.get();
      if (token !== null) {
        return token;
      } else {
        return null;
      }
    } catch (error) {
      throw error;
    }
  }
}
