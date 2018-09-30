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

export default class loginPage extends Component {
  static navigationOptions = {
    title: "Login Screen"
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
      <KeyboardAvoidingView>
        <View>
          <TextInput
            placeholder="Email"
            value={this.state.email}
            onChangeText={email => this.setState({ email })}
          />
          <TextInput
            placeholder="Password"
            value={this.state.password}
            onChangeText={password => this.setState({ password })}
          />
          <TouchableOpacity onPress={this.login.bind(this)}>
            <Text>Log In</Text>
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
    backgroundColor: "#3498db"
  }
});
