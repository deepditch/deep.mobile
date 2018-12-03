import React, { Component } from "react";
import {
    StyleSheet,
    Text,
    View,
    NetInfo,
} from "react-native";


function Offline() {
    return (
        <View style={styles.container}>
            <Text>Lost Internet Connection.</Text>
        </View>
    )
}

export default class NetInfoService extends Component {

    state = {
        isConnected: true,
    };


    render() {
        if (!this.state.isConnected) {
            return <Offline />;
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
            this.setState({ isConnected: true });
        }
        else {
            this.setState({ isConnected: false });
        }
        return;
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
