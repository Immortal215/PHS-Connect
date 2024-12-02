import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI
import FirebaseDatabase
import Pow
import SwiftUIX

struct CreateClubView: View {
    @State var clubTitle = ""
    @State var clubDesc = ""
    @State var clubAbstract = ""
    @State var schoology = ""
    @State var clubId = ""
    @State var location = ""
    @State var leaders: [String] = []
    @State var members: [String] = []
    @State var genres: [String] = []
    @State var genrePicker = "Non-Competitive"
    @State var clubPhoto = ""
    @State var normalMeet = ""
    @State var addLeaderText = ""
    @State var addMemberText = ""
    @State var leaderTextShake = false
    @State var memberTextShake = false
    @State var memberDisclosureExpanded = false
    @State var leaderDisclosureExpanded = false
    @State var genreDisclosureExpanded = false
    @State var clubType = "Course"
    
    var viewCloser: (() -> Void)?
    
    @State var CreatedClub : Club = Club(leaders: [], members: [], description: "", name: "", schoologyCode: "", abstract: "", showDataWho: "", clubID: "", location: "")
    @State var clubs: [Club] = []
    
    var body: some View {
        
        var abletoCreate: Bool {
            return (clubTitle != "" && clubDesc != "" && clubAbstract != "" && schoology.replacingOccurrences(of: "-", with: "").count > 12 && location != "" && !leaders.isEmpty)
        }
        
        VStack(alignment: .trailing) {
            if abletoCreate {
                Button {
                    if clubId == "" {
                        CreatedClub.clubID = "clubID\(clubs.count + 1)"
                    } else {
                        CreatedClub.clubID = clubId
                    }
                    
                    var cutSchool = schoology.replacingOccurrences(of: "-", with: "")
                    
                    CreatedClub.schoologyCode = String(cutSchool.prefix(4)) + "-" +
                                                String(cutSchool.dropFirst(4).prefix(4)) + "-" +
                                                String(cutSchool.dropFirst(8).prefix(5)) +
                                                " (\(clubType))"
                    CreatedClub.name = clubTitle
                    CreatedClub.description = clubDesc
                    CreatedClub.abstract = clubAbstract
                    CreatedClub.location = location
                    CreatedClub.leaders = leaders
                    
                    if !members.isEmpty {
                        CreatedClub.members = members
                    } else {
                        members.append(leaders[0])
                        CreatedClub.members = members
                    }
                    
                    if !genres.isEmpty {
                        CreatedClub.genres = genres
                    }
                    // create a picker for this
                    CreatedClub.showDataWho = "allNonGuest"
                    
                    // optional additions, needed to keep optional
                    if clubPhoto != "" {
                        CreatedClub.clubPhoto = clubPhoto
                    }
                    
                    if normalMeet != "" {
                        CreatedClub.normalMeetingTime = normalMeet
                    }
                    
                    addClub(club: CreatedClub)
                    viewCloser?()
                } label: {
                    Label {
                        Text(clubId == "" ? "Create Club" : "Edit Club")
                            .font(.headline)
                            .foregroundColor(.white)
                    } icon: {
                        Image(systemName: clubId == "" ? "plus" : "pencil")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(clubId == "" ? Color.green : Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .padding(.top)
                .padding(.trailing)
            } else {
                Button {
                    
                } label: {
                    Label {
                        Text("Info Not Complete!")
                            .font(.headline)
                            .foregroundColor(.white)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(.yellow)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .padding(.top)
                .padding(.trailing)
            }
            
            ScrollView {
                LabeledContent {
                    TextField("Club Name (Required)", text: $clubTitle)
                } label: {
                    Text("Club Name \(clubTitle.isEmpty ? "(Required)" : "")")
                        .foregroundStyle(clubTitle.isEmpty ? .red : .black)
                        .bold(clubTitle.isEmpty ? true : false)
                }
                .padding()
                
                
                LabeledContent {
                    TextField("Club Description (Required)", text: $clubDesc)
                } label: {
                    Text("Short Description \(clubDesc.isEmpty ? "(Required)" : "")")
                        .foregroundStyle(clubDesc.isEmpty ? .red : .black)
                        .bold(clubDesc.isEmpty ? true : false)
                }
                .padding()
                
                LabeledContent {
                    TextField("Club Abstract (Required)", text: $clubAbstract)
                } label: {
                    Text("Club Abstract \(clubAbstract.isEmpty ? "(Required)" : "")")
                        .foregroundStyle(clubAbstract.isEmpty ? .red : .black)
                        .bold(clubAbstract.isEmpty ? true : false)
                }
                .padding()
                
                DisclosureGroup(isExpanded: $leaderDisclosureExpanded) {
                    
                    HStack {
                        TextField("Add Leader Email(s) (Required)", text: $addLeaderText)
                            .padding()
                            .changeEffect(.shake(rate: .fast), value: leaderTextShake)
                            .onSubmit {
                                addLeaderFunc()
                            }
                        
                        Button {
                            addLeaderFunc()
                        } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(.green)
                        }
                        .padding()
                        
                        if !leaders.isEmpty {
                            Button {
                                leaders.removeLast()
                                addLeaderText = ""
                            } label: {
                                Image(systemName: "minus")
                                    .foregroundStyle(.red)
                            }
                            .padding()
                        }
                    }
                    .padding()
                    
                    ScrollView {
                        ForEach(leaders, id: \.self) { i in
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray, lineWidth: 3)
                                
                                Text("\(i)")
                                    .padding()
                                
                            }
                            .fixedSize()
                        }
                    }
                    .padding()
                    
                } label: {
                    Text("Edit Leaders \(leaders.isEmpty ? "(Required)" : "")")
                        .foregroundStyle(leaders.isEmpty ? .red : .black)
                        .bold(leaders.isEmpty ? true : false)
                }
                .padding()
                
                // schoology code
                LabeledContent {
                    TextField("Schoology Code (Required)", text: $schoology)
                        .padding()
                        .onAppear {
                            if schoology != "" {
                                clubType = schoology.contains("Course") ? "Course" : "Group"
                            }
                        
                        schoology = schoology.replacingOccurrences(of: " (Course)", with: "").replacingOccurrences(of:  " (Group)", with: "")
                    }

                    
                    Picker(selection: $clubType) {
                        Section("Club Type") {
                            Text("Course").tag("Course")
                            Text("Group").tag("Group")
                        }
                    }
                    
                } label: {
                    Text("Schoology Code \(schoology.replacingOccurrences(of: "-", with: "").count < 13 ? "(Required)" : "")")
                        .foregroundStyle(schoology.replacingOccurrences(of: "-", with: "").count < 13 ? .red : .black)
                        .bold(schoology.replacingOccurrences(of: "-", with: "").count < 13 ? true : false)
                }
                .padding()
                
                LabeledContent {
                    TextField("Club Location (Required)", text: $location)
                        .padding()
                } label: {
                    Text("Club Location \(location.isEmpty ? "(Required)" : "")")
                        .foregroundStyle(location.isEmpty ? .red : .black)
                        .bold(location.isEmpty ? true : false)
                }
                .padding()
                
                LabeledContent("Club Photo URL") {
                    TextField("Club Photo URL", text: $clubPhoto)
                }
                .padding()
                
                LabeledContent("Normal Meeting Times") {
                    TextField("Normal Meeting Times", text: $normalMeet)
                }
                .padding()
                
                DisclosureGroup("Edit Members", isExpanded: $memberDisclosureExpanded) {
                    VStack {
                        HStack {
                            TextField("Add Member Email(s) ", text: $addMemberText)
                                .padding()
                                .onSubmit {
                                    addMemberFunc()
                                }
                                .changeEffect(.shake(rate: .fast), value: memberTextShake)
                            
                            Button {
                                addMemberFunc()
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundStyle(.green)
                            }
                            .padding()
                            
                            if !members.isEmpty {
                                Button {
                                    members.removeLast()
                                    addMemberText = ""
                                } label: {
                                    Image(systemName: "minus")
                                        .foregroundStyle(.red)
                                }
                                .padding()
                            }
                        }
                        .padding()
                        
                        ScrollView {
                            ForEach(members, id: \.self) { i in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.gray, lineWidth: 3)
                                    
                                    Text("\(i)")
                                        .padding()
                                }
                                .fixedSize()
                            }
                        }
                        .padding()
                    }
                    
                }
                .padding()
                
                DisclosureGroup("Edit Genres", isExpanded: $genreDisclosureExpanded) {
                    
                    LabeledContent {
                        Picker(selection: $genrePicker) {
                            Text("Competitive").tag("Competitive")
                            Text("Non-Competitive").tag("Non-Competitive")
                            Section("Subjects") {
                                Text("Math").tag("Math")
                                Text("Science").tag("Science")
                                Text("Reading").tag("Reading")
                                Text("History").tag("History")
                                Text("Business").tag("Business")
                                Text("Technology").tag("Technology")
                                Text("Art").tag("Art")
                                Text("Fine Arts").tag("Fine Arts")
                                Text("Speaking").tag("Speaking")
                            }
                            Section("Descriptors") {
                                Text("Cultural").tag("Cultural")
                                Text("Physical").tag("Physical")
                                Text("Mental").tag("Mental")
                                Text("Safe Space").tag("Safe Space")
                            }
                        }
                        .padding()
                        
                        Button {
                            if !genres.contains(genrePicker) && genrePicker != "" {
                                genres.append(genrePicker)
                                genrePicker = ""
                            }
                        } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(.green)
                        }
                        .padding()
                        
                        if !genres.isEmpty {
                            Button {
                                genres.removeLast()
                                genrePicker = ""
                            } label: {
                                Image(systemName: "minus")
                                    .foregroundStyle(.red)
                            }
                            .padding()
                        }
                    } label: {
                        Text("Genres")
                    }
                    .padding()
                    
                    ScrollView {
                        ForEach(genres, id: \.self) { i in
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray, lineWidth: 3)
                                
                                Text("\(i)")
                                    .padding()
                            }
                            .fixedSize()
                        }
                    }
                    .padding()
                }
                .padding()
                
            }
            .textFieldStyle(.roundedBorder)
            .onAppear {
                leaders = CreatedClub.leaders
                members = CreatedClub.members
                clubId = CreatedClub.clubID
                clubTitle = CreatedClub.name
                clubDesc = CreatedClub.description
                clubAbstract = CreatedClub.abstract
                schoology = CreatedClub.schoologyCode
                location = CreatedClub.location
                genres = CreatedClub.genres ?? []
                if let photo = CreatedClub.clubPhoto {
                    clubPhoto = photo
                }
                if let meet = CreatedClub.normalMeetingTime {
                    normalMeet = meet
                }
                
            }
        }
    }

    func addLeaderFunc() {
        addLeaderText = addLeaderText.replacingOccurrences(of: " ", with: "")
        if (addLeaderText.contains("d214.org") || addLeaderText.contains("gmail.com")) && leaders.contains(addLeaderText) == false {
            if addLeaderText.contains(",") {
                let splitLeaders = addLeaderText.split(separator: ",")
                for i in splitLeaders {
                    leaders.append(String(i).lowercased())
                }
                addLeaderText = ""
                
            } else if addLeaderText.contains("/") {
                let splitLeaders = addLeaderText.split(separator: "/")
                for i in splitLeaders {
                    leaders.append(String(i).lowercased())
                }
                addLeaderText = ""
            } else if addLeaderText.contains(";") {
                let splitLeaders = addLeaderText.split(separator: ";")
                for i in splitLeaders {
                    leaders.append(String(i).lowercased())
                }
                addLeaderText = ""
            } else if addLeaderText.contains("-") {
                let splitLeaders = addLeaderText.split(separator: "-")
                for i in splitLeaders {
                    leaders.append(String(i).lowercased())
                }
                addLeaderText = ""
            } else {
                leaders.append(addLeaderText.lowercased())
                addLeaderText = ""
            }
        } else {
            leaderTextShake.toggle()
            dropper(title: "Enter a correct email!", subtitle: "Use the d214.org ending!", icon: UIImage(systemName: "trash"))
        }
    }
    
    func addMemberFunc() {
        addMemberText = addMemberText.replacingOccurrences(of: " ", with: "")
        if addMemberText.contains("d214.org") && members.contains(addMemberText) == false {
            if addMemberText.contains(",") {
                let splitMembers = addMemberText.split(separator: ",")
                for i in splitMembers {
                    members.append(String(i).lowercased())
                }
                addMemberText = ""
                
            }  else {
                members.append(addMemberText.lowercased())
                addMemberText = ""
            }
        } else {
            memberTextShake.toggle()
            dropper(title: "Enter a correct email!", subtitle: "Use the d214.org ending!", icon: UIImage(systemName: "trash"))
        }
    }
}
