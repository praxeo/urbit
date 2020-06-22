import React, { Component } from 'react';
import _ from 'lodash';
import moment from 'moment';

import { Link } from 'react-router-dom';

import { Message } from './lib/message';
import { ChatTabBar } from './lib/chat-tabbar';
import { PostInput } from './lib/post-input';
import { deSig } from '../../../lib/util';

export class NodeTreeScreen extends Component {
  constructor(props) {
    super(props);

    this.state = {};

    moment.updateLocale('en', {
      calendar: {
        sameDay: '[Today]',
        nextDay: '[Tomorrow]',
        nextWeek: 'dddd',
        lastDay: '[Yesterday]',
        lastWeek: '[Last] dddd',
        sameElse: 'DD/MM/YYYY'
      }
    });
  }

  parentPost() {
    const { props } = this;

    const node = props.node;
    if (!node) { return (<div></div>); }

    let prevIndex = node.post.index.split('/');
    prevIndex.pop();
    prevIndex = prevIndex.join('/');
    
    return (
      <div>
        <span className="dib f9 v-mid gray2 ml1 mr1 c-default inter">
          <Link className="dib f9 v-mid inter ml2 no-underline white-d"
             to={
               "/~post/room/" +
               `${props.resource.ship}/${props.resource.name}` +
               `${prevIndex}`
             }>
            ⟵
          </Link>
        </span>
        <Message
          isParent={true}
          key={node.post.index}
          msg={node.post}
        />
      </div>
    );
  }

  postWindow() {
    const { props } = this;

    let graph = !!props.node && 'children' in props.node ?
      props.node.children : new Map();
    let messages = Array.from(graph).reverse();

    const messageElements = messages.map((msg, i) => {
      let index = msg[0];
      let node = msg[1];
      let post = node.post;

      return (
        <Message
          key={post.index}
          resource={props.resource}
          index={post.index}
          msg={post}
          history={props.history}
        />
      );
    });

    return (
      <div
        className="overflow-y-scroll bg-white bg-gray0-d pt3 pb2 flex flex-column relative"
        style={{ height: '100%', resize: 'vertical' }}
      >
        {messageElements}
      </div>
    );
  }

  replyModal() {
    const { props, state } = this;

    return (
      <div>
        <PostInput
          api={props.api}
          resource={props.resource}
          owner={deSig(props.match.params.ship)}
          placeholder="Message..."
          parentIndex={props.parentIndex}
        />
      </div>
    );
  }

  render() {
    const { props } = this;

    let title = props.resource.name;

    return (
      <div
        key={props.resource.name}
        className="h-100 w-100 overflow-hidden flex flex-column relative"
      >
        <div
          className="w-100 dn-m dn-l dn-xl inter pt4 pb6 pl3 f8"
          style={{ height: '1rem' }}
        >
          <Link to="/~post/">{'⟵ All Graphs'}</Link>
        </div>
        <div
          className={'pl4 pt2 bb b--gray4 b--gray1-d bg-gray0-d flex relative' +
          'overflow-x-scroll overflow-x-auto-l overflow-x-auto-xl flex-shrink-0'}
          style={{ height: 48 }}
        >
          <Link to={`/~post/room/${props.resource.ship}/${props.resource.name}`}
          className="pt2 white-d"
          >
            <h2
              className={'dib f9 fw4 lh-solid v-top '}
              style={{ width: 'max-content' }}
            >
              {title}
            </h2>
          </Link>
          <ChatTabBar
            resource={props.resource}
            api={props.api}
          />
        </div>
        {this.parentPost()}
        {this.replyModal()}
        {this.postWindow()}
      </div>
    );
  }
}
