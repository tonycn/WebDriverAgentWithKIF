/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import PropTypes from 'prop-types';
import React from 'react';

import PubSub from 'pubsub-js'
import HTTP from 'js/http';
var Button = require('react-button');

require('css/inspector.css');

function boolToString(boolValue) {
  return boolValue === '1' ? 'Yes' : 'No';
}

class Inspector extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      script: ""
    }
    this.props.onRef(this)
    var selfRef = this;
    PubSub.subscribe("AddScriptCommandMessage", function (msg, command) {
      var commandLine = JSON.stringify(command)
      var scriptContent = selfRef.state['script'] + "\n" + commandLine
      selfRef.setState({
        script: scriptContent
      })
    })
  }

  render() {
    return (
      <div id="inspector" className="section third">
        <div className="section-caption">
          Inspector
        </div>
        <div className="section-content-container">
          <div className="section-content" style={{overflowY:'scoll'}}>
            {this.renderInspector()}
          </div>
          {this.renderScriptEditor()}
        </div>
      </div>
    );
  }

  renderInspector() {
    if (this.state.selectedNode == null) {
      return null;
    }

    const attributes = this.state.selectedNode.attributes;
    const tapButton =
      <span>
        <Button onClick={(event) => this.tap(this.state.selectedNode)}>
          Tap
        </Button>
        <Button onClick={(event) => this.assert(this.state.selectedNode)}>
          Assert
        </Button>
        <Button onClick={(event) => this.inputText(this.state.selectedNode)}>
          Text
        </Button>
        <Button onClick={(event) => this.hideKeyboard()}>
          Hide Keyboard
        </Button>
        <Button onClick={(event) => this.scroll(this.state.selectedNode)}>
          Scroll
        </Button>
      </span>
 

    return (
      <div>
        {this.renderField('Class', attributes.type)}
        {this.renderField('Path', attributes.classChain)}
        {this.renderField('Rect', attributes.rect)}
        {this.renderField('isEnabled', boolToString(attributes.isEnabled))}
        {this.renderField('Actions', tapButton, false)}
     </div>
    );
  }

  renderField(fieldName, fieldValue, castToString = true) {
    if (fieldValue == null) {
      return null;
    }
    var value;
    if (castToString) {
      value = String(fieldValue);
    } else {
      value = fieldValue;
    }
    return (
      <div className="inspector-field">
        <span className="inspector-field-caption">
          {fieldName}:
        </span>
        <span className="inspector-field-value">
          {value}
        </span>
      </div>
    );
  }

  renderScriptEditor() {
    const headerDiv =
      <span>
        <span> Script Editor </span>
        <Button onClick={(event) => this.execute(this.state.script)}>
          Execute
        </Button>
      </span>

    return (
          <div className="section-content" style={{height:'40%'}}>
            {headerDiv}
            <textarea className="inspector-script-text" 
            value={this.state.script} 
            onChange={(event) => {this.handleScriptChange(event)}} >
            </textarea>
          </div>
        )
  }

  handleScriptChange(event) {
    this.setState({
      script: event.target.value
    });
  }

  updateSelectedNode(node) {
    this.setState({
      selectedNode: node
    });
  }

  tap(node) {
    this.setState({selectedNode: null})
    HTTP.get(
      'status', (status_result) => {
        var session_id = status_result.sessionId;
        HTTP.post(
          'session/' + session_id + '/command',
          JSON.stringify({
            action: 'tap',
            classChain: node.attributes.classChain
          }),
          (result) => {
            PubSub.publish('AddScriptCommandMessage', result['value']['command']);
            setTimeout(function () {
              this.props.refreshApp();
            }.bind(this), 1000)
          },
        );
      },
    );
  }
  assert(node) {
    this.setState({selectedNode: null})
    HTTP.get(
      'status', (status_result) => {
        var session_id = status_result.sessionId;
        HTTP.post(
          'session/' + session_id + '/command',
          JSON.stringify({
            action: 'assert',
            classChain: node.attributes.classChain
          }),
          (result) => {
            PubSub.publish('AddScriptCommandMessage', result['value']['command']);
            setTimeout(function () {
              this.props.refreshApp();
            }.bind(this), 1000)
          },
        );
      },
    );
  }
  inputText(node) {

  }

  hideKeyboard() {
    HTTP.get(
      'status', (status_result) => {
        var session_id = status_result.sessionId;
        HTTP.post(
          'session/' + session_id + '/keyboard/dismiss',
          JSON.stringify({}),
          (result) => {
            console.log(result)
            PubSub.publish('AddScriptCommandMessage', result['value']['command']);
            setTimeout(function () {
              this.props.refreshApp();
            }.bind(this), 1000)
          },
        );
      },
    );
  }

  scroll(node) {
    let x = window.prompt('Scroll horizontal by distance x =', 0)
    let y = window.prompt('Scroll vertical by distance y =', 0)
    let findElement = window.prompt('Keep scrolling until next elememnt appears.')
    HTTP.get(
      'status', (status_result) => {
        var session_id = status_result.sessionId;
        HTTP.post(
          'session/' + session_id + '/scroll',
          JSON.stringify({
            x: x,
            y: y,
            on: node.attributes.classChain,
            until: findElement ? findElement  : ""
          }),
          (result) => {
            console.log(result)
            PubSub.publish('AddScriptCommandMessage', result['value']['command']);
            setTimeout(function () {
              this.props.refreshApp();
            }.bind(this), 1000)
          },
        );
      },
    );
  }

  drag(node) {
    let x = window.prompt('Drag horizontal by distance x =')
    let y = window.prompt('Drag vertical by distance y =')

  }
  execute(content) {
    this.setState({
      selectedNode: null
    })
    HTTP.get(
      'status', (status_result) => {
        var session_id = status_result.sessionId;
        HTTP.post(
          'session/' + session_id + '/script',
          JSON.stringify({
            script: content
          }),
          (result) => {
            console.log(result)
            setTimeout(function () {
              this.props.refreshApp();
            }.bind(this), 1000)
          },
        );
      },
    );
  }
}

Inspector.propTypes = {
  selectedNode: PropTypes.object,
};

module.exports = Inspector;
