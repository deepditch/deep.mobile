import React, { Component } from "react";
import {
    StyleSheet,
    Text,
    View,
    NetInfo,
} from "react-native";


export default class NetInfoService extends Component {

    state = {
        isConnected: true,
    };


    render() {
        if (!this.state.isConnected) {
            return (
                <View style={styles.container}>
                    <Text>Lost Internet Connection.</Text>
                </View>
            )
        }
        else
            return null;
    }


    componentDidMount() {
        NetInfo.isConnected.addEventListener('connectionChange', this._handleConnectionChange);
    }


    componentWillUnmount() {
        NetInfo.isConnected.removeEventListener('connectionChange', this._handleConnectionChange);
    }


    _handleConnectionChange = isConnected => {
        if (isConnected === true) {
           return this.setState({ isConnected: true });
        }
        else {
           return this.setState({ isConnected: false });
        }
        
    }

}

const styles = StyleSheet.create({
    container: {
        position: 'absolute',
        top: 573,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: "#808080",
        height: 30,
        flexDirection: 'row',
        width: '117%'
    }
})
