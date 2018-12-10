import AuthService from "./auth.service";
import config from "../../project.config";

export default class DamageService {
  constructor() {
    this.authService = new AuthService();
  }

  async parseJSON(response) {
    if (response.headers.authorization) {
      if (response.headers.authorization.startsWith('Bearer ')) {
        await this.authService.setToken(response.headers.authorization.substring('Bearer '.length));
      }
      else {
        await this.authService.setToken(response.headers.authorization);
      }
      
    }

    console.log(response);
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

  async getDamages() {
    var token = await this.authService.getToken();
    const requestBody = {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        authorization: "Bearer " + token
      }
    };

    return new Promise((resolve, reject) => {
      fetch(config.API_BASE_PATH + "/road-damage", requestBody)
        .then(this.parseJSON)
        .then(response => {
          console.log(response);
          if (!response.ok) return reject(response.json);
          return resolve(response.json.data);
        });
    });
  }
}
