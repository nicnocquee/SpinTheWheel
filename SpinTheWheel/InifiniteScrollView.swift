//
//  InifiniteScrollView.swift
//  SpinTheWheel
//
//  Created by Nico Prananta on 13.02.22.
//

import SwiftUI

let defaultRepeatCount = 1

let players = [
"Player 1",
"Player 2",
"Player 3",
"Player 4",
"Player 5",
"Player 6",
"Player 7",
"Player 8",
]

// https://stackoverflow.com/a/51076570/401544
// find the percentage of intersection between two rectangles
extension CGRect {
  func intersectionPercentage(_ otherRect: CGRect) -> CGFloat {
    if !intersects(otherRect) { return 0 }
    let intersectionRect = intersection(otherRect)
    if intersectionRect == self || intersectionRect == otherRect { return 100 }
    let intersectionArea = intersectionRect.width * intersectionRect.height
    let area = width * height
    let otherRectArea = otherRect.width * otherRect.height
    let sumArea = area + otherRectArea
    let sumAreaNormalized = sumArea / 2.0
    return intersectionArea / sumAreaNormalized * 100.0
  }
}

struct InifiniteScrollView: View {
  
  @State var rows = InifiniteScrollView.getRows()
  @State var yellowFrame = CGRect.zero
  
  init() {
    UITableView.appearance().showsVerticalScrollIndicator = false
  }
  
  func isMiddle(rowGeo: GeometryProxy, listGeo: GeometryProxy) -> Bool {
    let intersection = rowGeo.frame(in: .global).intersectionPercentage(yellowFrame)
    return floor(intersection) > 50
  }
  
  func distanceFromMiddle(rowGeo: GeometryProxy, listGeo: GeometryProxy) -> CGFloat {
    let distance = floor(abs(rowGeo.frame(in: .global).origin.y - listGeo.frame(in: .global).height / 2))
    return distance / (listGeo.frame(in: .global).height / 2)
  }
  
  var body: some View {
    VStack {
      GeometryReader { listGeo in
        ZStack {
          Rectangle()
            .path(in: yellowFrame)
            .fill(.yellow)
          List(rows, id: \.self) { row in
            GeometryReader { rowGeo in
              VStack(alignment: .center) {
                Spacer(minLength: 10)
                HStack(alignment: .center) {
                  Spacer()
                  Text(getName(from: row))
                    .multilineTextAlignment(.center)
                    .font(.system(size: isMiddle(rowGeo: rowGeo, listGeo: listGeo) ? 25 : 17, weight: isMiddle(rowGeo: rowGeo, listGeo: listGeo) ? .bold : .regular, design: .default)) // make the name bold if in the middle
                    .opacity(isMiddle(rowGeo: rowGeo, listGeo: listGeo) ? 1 : 1 - distanceFromMiddle(rowGeo: rowGeo, listGeo: listGeo)) // the further the rows from the center, reduce the opacity

                  Spacer()
                }
                Spacer(minLength: 10)
              }
              .onAppear {
                // if last row, add shuffled names to the rows
                if rows.last == row {
                  var newRows: [String] = [rows.last ?? ""]
                  // prevent same name one after another
                  while getName(from: newRows.first ?? "") == getName(from: rows.last ?? "") {
                    newRows = InifiniteScrollView.getRows(repeatCount: defaultRepeatCount, start: rows.count / players.count)
                  }
                  rows.append(contentsOf: newRows)
                }
              }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
          }
          .listStyle(.plain)
          .background(.clear)
        }
        .onAppear(perform: {
          yellowFrame = CGRect(x: listGeo.frame(in: .global).origin.x, y: (listGeo.frame(in: .global).height / 2) - 64, width: listGeo.frame(in: .global).width, height: 50.0)
        })
      }
    }
    .ignoresSafeArea()
    .background(.white)
  }
  
  func getName(from row: String) -> String {
    // remove the index from the row string
    let components = row.split(separator: "-")
    return components.first?.trimmingCharacters(in: .whitespaces) ?? row
  }
  
  static func getRows(repeatCount: Int = defaultRepeatCount, start: Int = 0) -> [String] {
    var rows: [String] = []
    let end = repeatCount + start
    for i in start..<end {
      rows.append(contentsOf: players.shuffled().map({ player in
        // append the index to prevent same name identified as equal
        "\(player) - \(i)"
      }))
    }
    return rows
  }
}

struct InifiniteScrollView_Previews: PreviewProvider {
    static var previews: some View {
        InifiniteScrollView()
    }
}
