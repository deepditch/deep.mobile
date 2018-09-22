import React, { Component } from 'react';
import {
  StyleSheet,
  Text,
  Dimensions,
  View,
  TextInput,
  KeyboardAvoidingView,
  TouchableOpacity,
  AsyncStorage
} from 'react-native';
import { StackNavigator } from 'react-navigation';

/* ================================================
Login page informatioon
===================================================
Basic login page.
Has a username and password placeholder (currently doesnt do anything but take input)
Has a login button that when clicked takes user to the camera screen.

=====================TO DO========================
*Sign up button.
*authentication
*Hide password with ***
*forgot password button
*connect to database
*verify session
*only allow user to access camera when logged in
*/

export default class loginPage extends React.Component {
  static navigationOptions =
    {
      title: 'Login Screen',
    };

  constructor(props) {
    super(props);
    this.state = {
      username: '',
      password: '',
    }
  }

  render() {
    const { navigate } = this.props.navigation;
    return (
      <View>

        <TextInput
          placeholder='Username'
          onChangeText={(username) => this.setState({ username })}
        ></TextInput>
        <TextInput placeholder="Password"
          onChangeText={(password) => this.setState({ password })}
        ></TextInput>
       
        <TouchableOpacity
          onPress={() => navigate('Camera')}>
          <Text>Log In</Text>
        </TouchableOpacity>

      </View>
    );
  }

}

const style = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#3498db'
  }
});