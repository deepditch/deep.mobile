import { AsyncStorage } from "react-native";
import config from "../../project.config";

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

  async setToken(token) {
    try {
      await AsyncStorage.setItem("@auth:token", token);
    } catch (error) {
      console.log(error);
      throw err;
    }
  }

  async getToken() {
    try {
      const token = await AsyncStorage.getItem("@auth:token");
      if (token !== null) {
        return token;
      } else {
        throw "No token";
      }
    } catch (error) {
      throw error;
    }
  }
}
