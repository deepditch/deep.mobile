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
import NetInfoService from "../services/netInfo.service";
import { ButtonStyle } from "../styles/button.style";
import { InputStyle } from "../styles/input.style";

export default class forgotPasswordPage extends Component {
  static navigationOptions = {
    title: "Forgot Password"
  };

  /*
  Forgot Password screen, contains only one field, email.
  */

  constructor(props) {
    super(props);
    this.state = {
      email: "",
      failAlert: "",
    };
  }

  render() {
    if (this.state.failAlert !== "") {
      alert(this.state.failAlert);
    }
    return (
      <KeyboardAvoidingView style={style.container} behavior="padding">
      <NetInfoService/> 
   <View>
          
          <Text style={[InputStyle.label, {paddingLeft:1}]}>Email</Text>
          <TextInput
            style={[InputStyle.input, {marginTop:0}]}
            placeholder="Email"
            label="Email"
            textContentType="emailAddress"
            autoCorrect={false}
            value={this.state.email}
            autoCapitalize="none"
            keyboardType="url"
            onChangeText={email => this.setState({ email, failAlert: "" })}
            onSubmitEditing={() => { this.submit(); }}
          />
      
         
          <TouchableOpacity
            onPress={this.submit.bind(this)}
            style={[ButtonStyle.button, { marginTop: 5 }, { alignSelf:"center" }]}
          >
            <Text style={ButtonStyle.buttonText}>Submit</Text>
          </TouchableOpacity>
          </View>
          <View style={{height:60}}/>
      </KeyboardAvoidingView>
    );
  }

/*
on submit sends the user an email. and sends the user back to the login screen.
*/

  submit() {
    
      new AuthService()
        .forgotPass(
          this.state.email,
        )
        .then(response => {
            alert("An email with instruction on how to reset your password was sent.")
          this.props.navigation.navigate("Home");
        })
        .catch(error => {
          if (error.message)
            this.setState({ failAlert: "Invalid Email: " + error.message });
          else this.setState({ failAlert: "Invalid Email" });
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
