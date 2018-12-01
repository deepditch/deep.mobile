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

export default class registrationPage extends Component {
  static navigationOptions = {
    title: "Registration"
  };

  constructor(props) {
    super(props);
    this.state = {
      name: "",
      email: "",
      password: "",
      confirmPassword: "",
      failAlert: ""
    };
  }

  render() {
    if (this.state.failAlert !== "") {
      alert(this.state.failAlert);
    }
    return (
      <KeyboardAvoidingView style={style.container} behavior="padding">
   <View>
          <Text style={InputStyle.label}>User Name</Text>
          <TextInput
            style={InputStyle.input}
            placeholder="User Name"
            label="User Name"
            textContentType="username"
            autoCorrect={false}
            value={this.state.name}
            autoCapitalize="none"
            onChangeText={name => this.setState({ name, failAlert: "" })}
           
            returnKeyType="next"
            onSubmitEditing={() => { this.emailField.focus(); }}
            blurOnSubmit={false}
          />
          <Text style={InputStyle.label}>Email</Text>
          <TextInput
            ref={(input) => { this.emailField = input }}

            style={InputStyle.input}
            placeholder="Email"
            label="Email"
            textContentType="emailAddress"
            autoCorrect={false}
            value={this.state.email}
            autoCapitalize="none"
            keyboardType="url"
            onChangeText={email => this.setState({ email, failAlert: "" })}

            returnKeyType="next"
            onSubmitEditing={() => { this.passwordField.focus(); }}
            blurOnSubmit={false}
          />
          <Text style={InputStyle.label}>Password</Text>
          <TextInput
            ref={(input) => { this.passwordField = input }}

            style={InputStyle.input}
            placeholder="Password"
            label="Password"
            textContentType="password"
            autoCorrect={false}
            value={this.state.password}
            autoCapitalize="none"
            secureTextEntry={true}
            onChangeText={password => this.setState({ password, failAlert: "" })}

            returnKeyType="next"
            onSubmitEditing={() => { this.confirmPasswordField.focus(); }}
            blurOnSubmit={false}
          />
          <Text style={InputStyle.label}>Confirm Password</Text>
          <TextInput
            ref={(input) => { this.confirmPasswordField = input }}

            style={InputStyle.input}
            placeholder="Confirm Password"
            label="Confirm Password"
            textContentType="password"
            autoCorrect={false}
            value={this.state.confirmPassword}
            autoCapitalize="none"
            secureTextEntry={true}
            onChangeText={confirmPassword => this.setState({ confirmPassword, failAlert: "" })}
            onSubmitEditing={() => { this.submit(); }}

          />
          <TouchableOpacity
            onPress={this.submit.bind(this)}
            style={[ButtonStyle.button, { marginTop: 0 }, { alignSelf:"center" }]}
          >
            <Text style={ButtonStyle.buttonText}>Submit</Text>
          </TouchableOpacity>
          </View>
          <View style={{height:60}}/>
      </KeyboardAvoidingView>
    );
  }

  submit() {
    if (this.state.password === this.state.confirmPassword) {
      new AuthService()
        .register(
          this.state.name,
          this.state.email,
          this.state.password
        )
        .then(response => {
          this.props.navigation.navigate("Home");
        })
        .catch(error => {
          if (error.message)
            this.setState({ failAlert: "Registration Failure: " + error.message });
          else this.setState({ failAlert: "Registration Failure" });
        });
    } else {
      this.setState({ failAlert: "Password confirmation does not match" });
    }
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    padding: 25,
    backgroundColor: "#eee"
  }
});
