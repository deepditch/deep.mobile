import React, { Component } from "react";
import { Text, Platform, View, TouchableOpacity } from "react-native";
import AuthService from "./services/auth.service";
import { StyleSheet, Dimensions } from "react-native";
import DamageCamera from "./damage-camera";
import DamageService from "./services/damage.service"

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

  // state = {
  //   token: null,
  //   damages: []
  // };

  constructor(props) {
    super(props);

    this.state = {
      token: null,
      damages: [],
      previousReports: {}
    };
    this.getValue = this.getValue.bind(this);
  }
  
  getValue() {
    return this.state.token;
  }

  componentDidMount() {
    if (Platform.OS === "ios") {
      //platform.OS detects if it ios or android and runs the respective permissions
      navigator.geolocation.requestAuthorization(); //so that both ios and android receives the right permissions and both work at the same time.
    } else {
      requestPermissions();
    }

      this.getPreviousReports()
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
  }

  _onDamageReported(event) {
    clearTimeout(this.statusTimeout);
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

  getPreviousReports() {
    new DamageService()
      .getDamages()
      .then(damages => {
        var reports = {}
        damages.forEach(dam => {
          if (!reports[dam.type]) reports[dam.type] = []
          reports[dam.type].push([dam.position.latitude, dam.position.longitude])
        })
        this.setState({ previousReports: reports });
      })
      .catch(error => {
        this.setState({ alert: "Failed to load damage locations" });
      });
  }

  render() {
    return (
      <DamageCamera
        style={styles.preview}
        onDamageDetected={this._onDamageDetected.bind(this)}
        onDamageReported={this._onDamageReported.bind(this)}
        onDownloadComplete={this._onDownloadComplete.bind(this)}
        onDownloadProgress={this._onDownloadProgress.bind(this)}
        onError={this._onError.bind(this)}
        previousReports={this.state.previousReports}
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
