import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI
import FirebaseDatabase
import Pow


struct ClubView: View {
    @State var clubs: [Club] = []
    @State var favoriteClubs: [Club] = []
     var screenWidth = UIScreen.main.bounds.width
     var screenHeight = UIScreen.main.bounds.height
    @AppStorage("shownInfo") var shownInfo = -1
    @State var searchText = ""
    var viewModel : AuthenticationViewModel
    
    var body: some View {
        
        // code to search club
        var filteredItems: [Club] {
                if searchText.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        
                        clubs = clubs.sorted { favoriteClubs.contains($0) && !favoriteClubs.contains($1) }
                    }
                    return clubs
                    
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        
                        clubs = clubs.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                        clubs = clubs.sorted { favoriteClubs.contains($0) && !favoriteClubs.contains($1) }
                    }
                        return clubs
                    
                }
            
            
        }
        
        // logic for checking who is allowed to see what information about each club
        var whoCanSeeWhat: Bool {
            switch clubs[shownInfo].showDataWho {
                case "all": return true
                    
            case "allNonGuest": return (!viewModel.isGuestUser && clubs[shownInfo].showDataWho == "allNonGuest")
                    
            case "onlyMembers": return (clubs[shownInfo].members.contains(viewModel.userEmail ?? "") || clubs[shownInfo].leaders.contains(viewModel.userEmail ?? ""))
                    
            case "onlyLeaders": return clubs[shownInfo].leaders.contains(viewModel.userEmail ?? "")
                    
                default: return false
                
            }
        }
        
        VStack {
            Text("Clubs")
                .font(.title)
            
            HStack {
                
                // each club
                ScrollView {
                
                    CustomSearchBar(text: $searchText, placeholder: "Search all clubs")
                    
                    ForEach(Array(filteredItems.enumerated()), id: \.element.name) { (index, club) in
                        ZStack {
                            Rectangle()
                                .stroke(.black, lineWidth: 3)
                            
                            HStack {
                                AsyncImage(url: URL(string: club.clubPhoto ?? "https://schoology.d214.org/sites/all/themes/schoology_theme/images/group-default.svg?0"), content: { Image in
                                    ZStack {
                                        Image
                                            .resizable()
                                            .clipShape(Rectangle())
                                        
                                        
                                        Rectangle()
                                            .stroke(.black, lineWidth: 3)
                                    }
                                    .frame(maxWidth: screenWidth/5, maxHeight: screenHeight/5)
                                    
                                }, placeholder: {
                                    ZStack {
                                        Rectangle()
                                            .stroke(.gray)
                                        ProgressView("Loading \(club.name) Image")
                                    }
                                    
                                })
                                .padding()
                               // .frame(width: screenWidth/5, height: screenHeight/5)
                                
                                Spacer()
                                
                                VStack {
                                    Text(club.name)
                                        .font(.callout)
                                    Text(club.description)
                                        .font(.caption)
                                    Spacer()
                                    if let genres = club.genres, !genres.isEmpty{
                                        Text("Genres : \(genres.joined(separator: ", "))")
                                            .font(.footnote)
                                            .foregroundStyle(.blue)
                                    }
                                }
                                .padding()
                                
                                VStack {
                                    Button {
                                        shownInfo = index
                                    } label : {
                                        Image(systemName : club.leaders.contains(viewModel.userEmail!) ? "pencil.circle" : "info.circle")
                                    }
                                    
                                    if !viewModel.isGuestUser {
                                        Button {
                                            getClubIDByName(clubName: clubs[index].name) { clubID in
                                                guard let clubID = clubID else {
                                                    print("Club ID not found.")
                                                    return
                                                }
                                                
                                                if let existingIndex = favoriteClubs.firstIndex(where: { $0.name == clubs[index].name }) {
                                                    
                                                    removeClubFromFavorites(for: viewModel.uid ?? "", clubID: clubID)
                                                    favoriteClubs.remove(at: existingIndex)
                                                    
                                                } else {
                                                    addClubToFavorites(for: viewModel.uid ?? "", clubID: clubID)
                                                    favoriteClubs.append(club)
                                                }
                                            }
                                        } label: {
                                            if favoriteClubs.contains(club) {
                                                Image(systemName: "heart.fill")
                                                    .transition(.movingParts.pop(.blue))
                                            } else {
                                                Image(systemName: "heart")
                                                    .transition(.identity)
                                            }
                                        }
                                        .padding(.top)
                                    }
                                }
                                .padding()
                                .padding(.bottom, screenWidth/10)
                                
                            }
                        }
                        .padding()
                    }
                    
                    if filteredItems.isEmpty {
                        Text("No Clubs Found for \"\(searchText)\"")
                    }
                    
                    
                }
                .frame(width: screenWidth/2)
                .padding(.leading)
                //.fixedSize()
                
                
                // clubs data
                ScrollView {
                    
                    if shownInfo >= 0 && shownInfo < clubs.count {
                        
                        VStack (alignment:.leading, spacing: 8) {
                            VStack (alignment: .center) {
                                // Club Name
                                Text(clubs[shownInfo].name)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                // Club Description
                                Text(clubs[shownInfo].abstract)
                                    .font(.body)
                                    .foregroundColor(.gray)
                                
                                // Club Photo
                                AsyncImage(url: URL(string: clubs[shownInfo].clubPhoto ?? "https://schoology.d214.org/sites/all/themes/schoology_theme/images/group-default.svg?0"), content: { Image in
                                    ZStack {
                                        Image
                                            .resizable()
                                            .clipShape(Rectangle())
                                        
                                        
                                        Rectangle()
                                            .stroke(.black, lineWidth: 3)
                                    }
                                    .frame(width: screenWidth/5, height: screenHeight/5)
                                    
                                }, placeholder: {
                                    ZStack {
                                        Rectangle()
                                            .stroke(.gray)
                                        ProgressView("Loading \(clubs[shownInfo].name) Image")
                                    }
                                    
                                })
                                .padding()
                                .frame(width: screenWidth/5, height: screenHeight/5)
                            }
                            
                            // Leaders
                            if !clubs[shownInfo].leaders.isEmpty {
                                Text("Leaders (\(clubs[shownInfo].leaders.count)):")
                                    .font(.headline)
                                ForEach(clubs[shownInfo].leaders, id: \.self) { leader in
                                    CodeSnippetView(code: leader)
                                    
                                }
                            }
                            
                            if whoCanSeeWhat {
                                
                                // Members
                                if !clubs[shownInfo].members.isEmpty {
                                    
                                    var mem = clubs[shownInfo].members.joined(separator: ", ")
                                    
                                    Text("Members (\(clubs[shownInfo].members.count)):")
                                        .font(.headline)
                                    
                                    CodeSnippetView(code: mem)
                                    
                                }
                                
                                // Meeting Times
                                if let meetingTimes = clubs[shownInfo].meetingTimes {
                                    Text("Meeting Times:")
                                        .font(.headline)
                                    ForEach(meetingTimes.keys.sorted(), id: \.self) { day in
                                        if let times = meetingTimes[day] {
                                            Text("\(day): \(times.joined(separator: ", "))")
                                                .font(.subheadline)
                                        }
                                    }
                                }
                                
                                // Announcements
                                if let announcements = clubs[shownInfo].announcements {
                                    Text("Announcements:")
                                        .font(.headline)
                                    ForEach(announcements.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                        Text("\(key): \(value)")
                                            .font(.subheadline)
                                    }
                                }
                            }
                            // Genres
                            if let genres = clubs[shownInfo].genres, !genres.isEmpty {
                                Text("Genres:")
                                    .font(.headline)
                                
                                Text(genres.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                            }
                            
                            // Schoology Code
                            HStack {
                                Text("Schoology Code: ")
                                CodeSnippetView(code: clubs[shownInfo].schoologyCode)
                            }
                            
                        }
                        .padding()
                       
                    } else {
                        Text("Choose a Club!")
                    }
                    
                    Color.white
                        .frame(height: screenHeight/3)
                }
                .frame(width: screenWidth/2)
                
                
            }
        }
        .onAppear {
            fetchClubs { fetchedClubs in
                self.clubs = fetchedClubs
            }
            if !viewModel.isGuestUser {
                    fetchUserFavoriteClubs(userID: viewModel.uid ?? "") { favoredClubs in
                        self.favoriteClubs = favoredClubs
                    }
            }
        }
        
    }
}