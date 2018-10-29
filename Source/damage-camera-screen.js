import React, { Component } from "react";
import { Text, Platform, View } from "react-native";
import AuthService from "./services/auth.service";
import { StyleSheet, Dimensions } from "react-native";
import DamageCamera from "./damage-camera";

class DamageLabels extends Component {
  render() {
    return (
      <>
        {this.props.damages &&
          this.props.damages.map(damage => (
            <Text style={styles.pop}>{damage.type}: {damage.description} ({damage.confidence})</Text>
          ))}
      </>
    );
  }
}

class UploadMSG extends Component {
  render() {
    if (!this.props.msg) return null;

    return (
      <>
        {this.props.msg && (
          <Text
            style={[
              styles.pop,
              this.props.status == "ok" ? styles.ok : styles.err
            ]}
          >
            {this.props.msg}
          </Text>
        )}
      </>
    );
  }
}

export default class DamageCameraScreen extends Component {
  //static navigationOptions = {
    //title: "Camera"
    static navigationOptions = function(props) {
      return{
          //title: "Map",
       headerLeft:
    <Text onPress={()=>props.navigation.openDrawer()}>Menu</Text>
  };}

  state = {
    token: null,
    damages: []
  };

  constructor(props) {
    super(props);
  }

  componentDidMount() {
    if (Platform.OS === "ios") {
      //platform.OS detects if it ios or android and runs the respective permissions
      navigator.geolocation.requestAuthorization(); //so that both ios and android receives the right permissions and both work at the same time.
    } else {
      requestPermissions();
    }

    new AuthService()
      .getToken()
      .then(token => {
        this.setState({
          token: token
        });
      })
      .catch(err => {
        console.log(err);
      });
  }

  _onDamageDetected(event) {
    clearTimeout(this.damagesTimeout);
    this.setState({ damages: event.damages });
    this.damagesTimeout = setTimeout(
      function() {
        this.setState({ damages: [] });
      }.bind(this),
      3000
    );
  }

  _onDamageReported(event) {
    clearTimeout(this.statusTimeout);
    console.log(event);
    if (event.status == 201 || event.status == 200) {
      this.setState({ status: "ok", msg: "Upload Successful" });
    } else {
      this.setState({ status: "err", msg: "Failed To Upload" });
    }
    this.statusTimeout = setTimeout(
      function() {
        this.setState({ msg: "" });
      }.bind(this),
      3000
    );
  }

  render() {
    if (!this.state.token) {
      return (
        <View>
          <Text>Loading...</Text>
        </View>
      );
    }

    return (
      <DamageCamera
        style={styles.preview}
        onDamageDetected={this._onDamageDetected.bind(this)}
        onDamageReported={this._onDamageReported.bind(this)}
        authToken={this.state.token}
      >
        <UploadMSG msg={this.state.msg} status={this.state.status} />
        <DamageLabels damages={this.state.damages} />
      </DamageCamera>
    );
  }
}

const styles = StyleSheet.create({
  preview: {
    flex: 1,
    justifyContent: "flex-end",
    alignItems: "center",
    height: Dimensions.get("window").height,
    width: Dimensions.get("window").width
  },
  pop: {
    flex: 0,
    backgroundColor: "#ffffff",
    borderRadius: 5,
    color: "#000",
    padding: 10,
    margin: 5
  },
  ok: {
    backgroundColor: "#00ff00"
  },
  err: {
    backgroundColor: "#ff0000",
    color: "#fff"
  }
});
