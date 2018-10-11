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
            username: "",
            email: "",
            password: "",
            confirmPassword:"",
            alert: "",
        };
    }

    render() {
        return (
            <KeyboardAvoidingView style={style.container}>
                <View>
                <Text style={InputStyle.label}>User Name</Text>
                    <TextInput
                        style={InputStyle.input}
                        placeholder="User Name"
                        label="User Name"
                        textContentType="username"
                        value={this.state.username}
                        autoCapitalize="none"
                        
                        onChangeText={username => this.setState({ username, alert: "" })}
                    />
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
                        <Text style={InputStyle.label}>Confirm Password</Text>
                    <TextInput
                        style={InputStyle.input}
                        placeholder="Confirm Password"
                        label="Confirm Password"
                        textContentType="password"
                        value={this.state.confirmPassword}
                        autoCapitalize="none"
                        secureTextEntry={true}
                        onChangeText={confirmPassword => this.setState({ confirmPassword, alert: "" })}
                    />
                    <TouchableOpacity
                        onPress={this.submit.bind(this)}
                        style={[ButtonStyle.button, { marginTop: 20 }, {marginleft : 20}]}
                    >
                        <Text style={ButtonStyle.buttonText}>Submit</Text>
                    </TouchableOpacity>
                    <Text>{this.state.alert}</Text>
                </View>
            </KeyboardAvoidingView>
        );
    }

    submit() {
        console.log(this.state);

        //alert(this.state.username);
       // alert(this.state.email);
    //    alert(this.state.password);
       // alert(this.state.confirmPassword);
        
        new AuthService()
            .register(this.state.username, this.state.email, this.state.password, this.state.confirmPassword)
            .then(response => {
                this.props.navigation.navigate("Home");
            })
            .catch(error => {
                if (error.message)
                    this.setState({ alert: "Registration Failure: " + error.message });
                else this.setState({ alert: "Registration Failure" });
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
