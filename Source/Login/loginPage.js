import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView
} from "react-native";

import axios from "axios";

export default class loginPage extends Component {
  static navigationOptions = {
    title: "Login Screen"
  };

  constructor(props) {
    super(props);
    this.state = {
      email: "",
      password: ""
    };
  }

  render() {
    const { navigate } = this.props.navigation;
    return (
      <KeyboardAvoidingView>
        <View>
          <TextInput
            placeholder="Email"
            onChangeText={email => this.setState({ email })}
          />
          <TextInput
            placeholder="Password"
            onChangeText={password => this.setState({ password })}
          />
          <TouchableOpacity onPress={this.loginF}>
            <Text>Log In</Text>
          </TouchableOpacity>
        </View>
      </KeyboardAvoidingView>
    );
  }

  loginF = () => {
    axios
      .post("http://216.126.231.155/api/login", {
        email: this.state.email,
        password: this.state.password
      })
      .then(response => {
        console.log(response);
        this.props.navigation.navigate('Camera');
      })
      .catch(err => {
        console.log(err);
      });
  };
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#3498db"
  }
});
