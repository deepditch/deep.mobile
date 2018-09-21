import React, {Component} from 'react';
import { StyleSheet, Text, Dimensions, View, Navigator} from 'react-native';




export default class loginPage extends Component {
  render() {
    return (
      <View style={StyleSheet.container}>
      <Text> TESTING THE DAMN LOGIN PAGE</Text>
      </View>
    );
  }

}

const style = StyleSheet.create({
    container:{
        flex:1,
        backgroundColor: '#3498db'
    }
});