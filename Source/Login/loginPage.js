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
      email: "classdemo@gmail.com",
      password: "asdfasdf",
      alert: ""
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
            autoCapitalize="none"
            keyboardType = "email-address"
            onChangeText={email => this.setState({ email, alert: "" })}
            
          />
          <Text style={InputStyle.label}>Password</Text>
          <TextInput
            style={InputStyle.input}
            placeholder="Password"
            label="Password"
            textContentType="password"
            value={this.state.password}
            autoCapitalize="none"
            secureTextEntry={true}
            onChangeText={password => this.setState({ password, alert: "" })}
          />
          </View>
          <View style ={ButtonStyle.bContainer}>
          <TouchableOpacity
            onPress={this.login.bind(this)}
            style={[ButtonStyle.button, { marginTop: 10 }]}
          >
            <Text style={ButtonStyle.buttonText}>LOG IN</Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={()=>this.props.navigation.navigate('Register')}
            style={[ButtonStyle.button,{ marginTop:10 }]}
          >
            <Text style={ButtonStyle.buttonText}>REGISTER</Text>
          </TouchableOpacity>
          <Text>{this.state.alert}</Text>
        </View>
      </KeyboardAvoidingView>
    );
  }

  login() {
    console.log(this.state);
   // alert(this.state.email);
   // alert(this.state.password);
    new AuthService()
      .login(this.state.email, this.state.password)
      .then(response => {
        this.props.navigation.navigate("Map");
      })
      .catch(error => {
        if (error.message)
          this.setState({ alert: "Login Failure: " + error.message });
        else this.setState({ alert: "Login Failure" });
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
