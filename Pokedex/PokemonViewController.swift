import UIKit

class PokemonViewController: UIViewController {
    
    var url: String!
    
    

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var catchButton: UIButton!
    @IBOutlet var spriteImage: UIImageView!
    
    var isCaught = false
    let defaults = UserDefaults.standard
    
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nameLabel.text = ""
        numberLabel.text = ""
        type1Label.text = ""
        type2Label.text = ""
        
        loadPokemon()
        isCaught = getPreferences()
        if isCaught {
            catchButton.setTitle("Release", for: .normal)
        } else {
            catchButton.setTitle("Catch", for: .normal)
        }
    }

    func loadPokemon() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                DispatchQueue.main.async {
                    self.navigationItem.title = self.capitalize(text: result.name)
                    self.nameLabel.text = self.capitalize(text: result.name)
                    self.numberLabel.text = String(format: "#%03d", result.id)

                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                        }
                    }
                    let imageURL = URL(string: result.sprites.front_default)
                    let imageData = try! Data(contentsOf: imageURL!)
                    self.spriteImage.image = UIImage(data: imageData)
                
                    
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    @IBAction func toggleCatch(_ sender: UIButton) {
        
        isCaught = !isCaught
        if isCaught {
            sender.setTitle("Release", for: .normal)
            //isCaught = true
        } else {
            sender.setTitle("Catch", for: .normal)
            //isCaught = false
        }
        
        savePreferences()
    }
    
    func savePreferences() {
        defaults.set(isCaught, forKey: "isCaught")
    }
    
    func getPreferences() -> Bool {
        return defaults.bool(forKey: "isCaught")
    }
}
