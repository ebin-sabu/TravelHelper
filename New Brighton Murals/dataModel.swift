//
//  dataModel.swift
//  New Brighton Murals
//
//  Created by Ebin Pereppadan on 13/12/2022.
//
import Foundation

struct img: Decodable{
    let id: String
    let filename: String
}

struct murals: Decodable {
    let id: String
    let title: String
    let artist: String?
    let info: String?
    let thumbnail: String?
    let lat: String?
    let lon: String?
    let enabled: String
    let lastModified: String
    let images: [img]
}
struct muralList: Decodable {
    var newbrighton_murals: [murals]
}
/*
"id":"1",
"title":"I See The Sea",
"artist":"Ben Eine",
"info":"Overlooking a secure car park Ben Eine's 'I See The Sea' is a bright neon yellow mural which is just pure fun. Known for his use of different typefaces he will often paint statements big and bold on walls he is asked to paint. If he's anything like me, growing up away from the seaside then the excited childish cry of 'I see the sea' was a familiar one when, on family trips, we got near the coast.",
"thumbnail":"https:\/\/cgi.csc.liv.ac.uk\/~phil\/Teaching\/COMP228\/nbm_thumbs\/IMG_1065X.JPG",
"lat":"53.43881250167621",
"lon":"-3.0416222190640183",
"enabled":"1",
"lastModified":"2022-11-21 12:02:37",
*/
