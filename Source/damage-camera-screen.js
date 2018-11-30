import React, { Component } from "react";
import { Text, Platform, View, TouchableOpacity } from "react-native";
import AuthService from "./services/auth.service";
import DamageService from "./services/damage.service";
import { StyleSheet, Dimensions } from "react-native";
import DamageCamera from "./damage-camera";

class DamageLabels extends Component {
  constructor(props) {
    super(props)
    this.refs = {};
  }

  render() {
    return (
      <>
        {this.props.damages &&
          this.props.damages.map((damage, idx) => (
            <Text style={styles.pop} key={idx}>
              {damage.type}: {damage.description} ({damage.confidence})
            </Text>
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
    return {
      //title: "Map",
      headerLeft: (
        <TouchableOpacity onPress={() => props.navigation.openDrawer()}>
          <Text>Menu</Text>
        </TouchableOpacity>
      )
    };
  };

  constructor(props) {
    super(props);

    this.state = {
      token: null,
      damages: []
    };

    this.reports = [];
    this.damageService = new DamageService();
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

    this._interval = setInterval(this.reportDamage.bind(this), 125);
  }

  reportDamage() {
    if (this.reports.length == 0) return;

    bestReport = this.reports.reduce(function(a, b) {
      return a.confidence > b.confidence ? a : b;
    });

    clearTimeout(this.statusTimeout);

    this.damageService
      .reportDamage(bestReport)
      .then(response => {
        this.setState({ status: "ok", msg: "Upload Successful" });
      })
      .catch(error => {
        this.setState({ status: "err", msg: "Failed To Upload" });
      });

    this.statusTimeout = setTimeout(
      function() {
        this.setState({ msg: "" });
      }.bind(this),
      3000
    );

    this.reports = [];
  }

  _onDownloadProgress(event) {
    console.log("View: ", event.progress)
    clearTimeout(this.progressTimeout);
    this.setState({
      status: "ok",
      msg: `Downloading... \n ${Math.round(event.progress * 100)}%`
    });
    this.progressTimeout = setTimeout(
      function() {
        this.setState({ msg: "" });
      }.bind(this),
      3000
    );
  }

  _onDownloadComplete(event) {
    clearTimeout(this.progressTimeout);
    this.setState({ status: "ok", msg: "Download Complete" });
    this.progressTimeout = setTimeout(
      function() {
        this.setState({ msg: "" });
      }.bind(this),
      3000
    );
  }

  _onError(event) {
    this.setState({
      status: "err",
      msg: "Model failed to download or compile"
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

    this.reports.push(event);
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
        onDownloadComplete={this._onDownloadComplete.bind(this)}
        onDownloadProgress={this._onDownloadProgress.bind(this)}
        onError={this._onError.bind(this)}
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
    alignItems: "center"
  },
  pop: {
    flex: 0,
    backgroundColor: "#ffffff",
    borderRadius: 5,
    color: "#000",
    padding: 10,
    margin: 5,
    textAlign: "center"
  },
  ok: {
    backgroundColor: "#00ff00"
  },
  err: {
    backgroundColor: "#ff0000",
    color: "#fff"
  }
});
