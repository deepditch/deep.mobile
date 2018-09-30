import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView
} from "react-native";

import AuthService from "../services/auth.service";
import { ButtonStyle } from "../styles/button.style";
import { InputStyle } from "../styles/input.style";

export default class loginPage extends Component {
  static navigationOptions = {
    title: "Login"
  };

  constructor(props) {
    super(props);
    this.state = {
      email: "test@gmail.com",
      password: "test"
    };
  }

  render() {
    return (
      <KeyboardAvoidingView style={style.container}>
        <View>
          <Text style={InputStyle.label}>Email</Text>
          <TextInput
            style={InputStyle.input}
            placeholder="Email"
            label="Email"
            textContentType="emailAddress"
            value={this.state.email}
            onChangeText={email => this.setState({ email })}
          />
          <Text style={InputStyle.label}>Password</Text>
          <TextInput
            style={InputStyle.input}
            placeholder="Password"
            label="Password"
            textContentType="password"
            value={this.state.password}
            onChangeText={password => this.setState({ password })}
          />
          <TouchableOpacity
            onPress={this.login.bind(this)}
            style={[ButtonStyle.button, { marginTop: 10 }]}
          >
            <Text style={ButtonStyle.buttonText}>LOG IN</Text>
          </TouchableOpacity>
        </View>
      </KeyboardAvoidingView>
    );
  }

  login() {
    new AuthService()
      .login(this.state.email, this.state.password)
      .then(response => {
        this.props.navigation.navigate("Camera");
      })
      .catch(error => {
        alert("Login Failure");
      });
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    padding: 25,
    backgroundColor: "#eee"
  }
});
