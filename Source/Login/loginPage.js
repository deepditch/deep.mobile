import React, { Component } from "react";
import {
    StyleSheet,
    Text,
    View,
    TextInput,
    TouchableOpacity,
    Dimensions,
    AsyncStorage,
    KeyboardAvoidingView
} from "react-native";
import { StackNavigator } from 'react-navigation';

/*
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
                        placeholder='Email'
                        onChangeText={(email) => this.setState({ email })}
                    ></TextInput>
                    <TextInput placeholder="Password"
                        onChangeText={(password) => this.setState({ password })}
                    ></TextInput>
                    <TouchableOpacity
                        onPress={this.loginF}>
                        <Text>Log In</Text>
                    </TouchableOpacity>
                </View>
            </KeyboardAvoidingView>
        ); // onPress={() => navigate('Camera')}>
    }
    /*
   Fetch is supposed to connect to the fornt end api.
   Using POST to send the login information.
   stringifying the email and password and sending to the web
   ---
   here get a token error which im not sure how to fix it.
   It might be because the website doesn't use json, but not sure -safayeth.
   */
    loginF = () => {
        //  alert(this.state.email);
        fetch('http://216.126.231.155/login?', {
            method: 'POST',
            header: {
                'Accept': 'application/json, text/plain',
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(
                {
                    email: this.state.email,
                    password: this.state.password,
                })
        })
            // .then((response) => response.json())
            .then((res) => {
                if (res.successs == true) {
                    this.props.navigation.navigate('Camera');
                }
                else {
                    alert(res.alertuser);
                }
            }
            )
            .done();
    }
}
    const style = StyleSheet.create({
        container: {
            flex: 1,
            backgroundColor: "#3498db"
        }
    });
