import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  Alert
} from "react-native";

import { AsyncStorage } from "react-native";


import AuthService from "../services/auth.service";
import NetInfoService from "../services/netInfo.service";
import { ButtonStyle } from "../styles/button.style";
import { InputStyle } from "../styles/input.style";

export default class loginPage extends Component {
  static navigationOptions = {
    title: "Login"
  };

  constructor(props) {
    super(props);
    this.state = {
      email: "",
      password: "",
      failAlert: "",
      currentToken: null,
    };
  }

  render() {
    if (this.state.failAlert !== "") {
      alert(this.state.failAlert);
    }

    return (
      <KeyboardAvoidingView style={style.container}>
        <NetInfoService />

        <View>

          <Text style={InputStyle.label}>Email</Text>
          <TextInput
            //clearButtonMode ="always"
            style={InputStyle.input}
            placeholder="Email"
            label="Email"
            textContentType="emailAddress"
            value={this.state.email}
            autoCapitalize="none"
            autoCorrect={false}
            keyboardType="url"
            onChangeText={email => this.setState({ email, failAlert: "" })}
            returnKeyType="next"
            onSubmitEditing={() => { this.passwordField.focus(); }}
            blurOnSubmit={false}
          />

          <Text style={InputStyle.label}>Password</Text>
          <TextInput
            //clearButtonMode ="always"
            ref={(input) => { this.passwordField = input }}
            style={InputStyle.input}
            placeholder="Password"
            label="Password"
            textContentType="password"
            value={this.state.password}
            autoCapitalize="none"
            autoCorrect={false}
            secureTextEntry={true}
            onChangeText={password => this.setState({ password, failAlert: "" })}
            onSubmitEditing={() => { this.login(); }}
          />    
        </View>

        <View style={ButtonStyle.bContainer}>

          <TouchableOpacity
            onPress={this.login.bind(this)}
            style={[ButtonStyle.button, { marginTop: 10 }]}
          >
            <Text style={ButtonStyle.buttonText}>LOG IN</Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={() => this.props.navigation.navigate('Register')}
            style={[ButtonStyle.button, { marginTop: 10 }]}
          >
            <Text style={ButtonStyle.buttonText}>REGISTER</Text>
          </TouchableOpacity>

        </View>

        <View>
        <TouchableOpacity
           onPress={() => this.props.navigation.navigate('ForgotPass')}
            style={[ButtonStyle.button, { top: 0 }, {alignSelf:"center"}]}
          >
            <Text style={ButtonStyle.buttonText}>Forgot Password?</Text>
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
        if (error.message)
          this.setState({ failAlert: "Login Failure: " + error.message });
        else this.setState({ failAlert: "Login Failure" });
      });

    this.clearAfterSubmit();
  }

  clearAfterSubmit() {
    this.setState({
      email: '',
      password: ''
    })
  }

  async componentDidMount() {
    new AuthService().getToken().then(token => {
      console.log(token)
      this.setState({ currentToken: token });
      this.props.navigation.navigate("Camera");
    }).catch(error => {
      this.setState({ currentToken: null });
    })
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    padding: 25,
    backgroundColor: "#eee"
  }
});
