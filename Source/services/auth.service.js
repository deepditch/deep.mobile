import axios from "axios";
import { AsyncStorage } from "react-native";

export default class AuthService {
  async login(email, password) {
    return axios
      .post("http://216.126.231.155/api/login", {
        email: email,
        password: password
      })
      .then(response => {
        this.setToken(response.data.access_token);
        return response.data;
      })
      .catch(err => {
        console.error(err);
        throw err;
      });
  }

  async setToken(token) {
    try {
      await AsyncStorage.setItem("@auth:token", token);
    } catch (error) {
      console.error(error);
      throw err;
    }
  }

  async getToken() {
    try {
      const token = await AsyncStorage.getItem("@auth:token");
      if (token !== null) {
        return token;
      }
    } catch (error) {
      throw error;
    }
  }
}
