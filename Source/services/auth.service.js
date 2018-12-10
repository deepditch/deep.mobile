import { AsyncStorage } from "react-native";
import config from "../../project.config";

/**
 * Most of the fetch request are sent from this file.
 */

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
                                      //Retrieves information from the registration page.
    const requestBody = {             // Request body set up the post request with the required headers
      method: "POST",                 // from the api endpoints to connect successfully.
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "x-requested-with": "XMLHttpRequest"
      },
      body: JSON.stringify(data)
    };

    return new Promise((resolve, reject) => {
      fetch(config.API_BASE_PATH + "/register", requestBody)  // makes a fetch request with the user data.
        .then(this.parseJSON)                                 
        .then(response => {
          console.log(response)
          if (!response.ok) return reject(response.json);
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

    return new Promise((resolve, reject) => {
      fetch(config.API_BASE_PATH + `/forgot-password?email=${email}`, {method:"GET"})   //This fetch sends a query with the GET method.
        .then(response => {
          console.log(response)
          if (!response.ok) return reject(response.json);
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
        return null;
      }
    } catch (error) {
      throw error;
    }
  }
}
