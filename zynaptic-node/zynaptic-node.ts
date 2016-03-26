/**
 * @name Zynaptic Node
 * @description 
 * @date 2015-03-12
 * @author Patrik Fosberg <mail@patrikforsberg.net>
 * @web www.patrikforsberg.net
 * @copyright Patrik Forsberg, some rights reserved
 * 
 * @history
 * TypeScript implementation of my old work horse
 * PutteNode, written in Object Pascal, the original
 * implementation as well as C#, Java and Erlang
 * implementations can be found here:
 * www.patrikforsberg.net/zynaptic-node/implementations
 * 
 * In order to use this piece of software, this file header
 * must remain intact.
 * 
 * Zynaptic Node is licensed under the Creative Commons
 * ### License, for more information, follow this link:
 * https://creativecommons.org
*/

/// <reference path="typings/main.d.ts" />

interface StructuredNode {
    ChildNodes: StructuredNode[];

}

// Implementation
class ZynapticNode implements StructuredNode {
    private nodeName: string; 
    ChildNodes: StructuredNode[];

    constructor(nodeName?:string) {
        this.ChildNodes = new Array<StructuredNode>(); 
    }
    
    get NodeName(): string {
        return this.nodeName;
    }
    
    set NodeName(value: string) {
        this.nodeName = value;
    }

    public newChildNode(): ZynapticNode {
        var newNode = new ZynapticNode();
        this.ChildNodes.push(newNode);
        return newNode;
    }
}

export { ZynapticNode }
