import UIKit

class PokemonViewController: UIViewController {
    
    var url: String!
    
    

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var catchButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var spriteImage: UIImageView!
    
    var isCaught = false
    let defaults = UserDefaults.standard
    var descriptionURL: String!
    
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nameLabel.text = ""
        numberLabel.text = ""
        type1Label.text = ""
        type2Label.text = ""
        descriptionLabel.text = ""
        
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
                    self.descriptionURL = result.species.url
                    self.pokemonDescription()
                    
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    func pokemonDescription() {
        guard let pokemonDescriptionURL = URL(string: descriptionURL) else {
            return
        }
        URLSession.shared.dataTask(with: pokemonDescriptionURL) { (data, response, error) in
            guard let data = data else {
                return
            }
            do {
                let result = try JSONDecoder().decode(PokemonDescription.self, from: data)
                DispatchQueue.main.async {
                    for index in 0..<result.flavor_text_entries.count {
                        if result.flavor_text_entries[index].language.name == "en" {
                            self.descriptionLabel.text = result.flavor_text_entries[index].flavor_text
                        }
                    }
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    

    
//    func parseJSON(_ weatherData: Data) -> WeatherModel? {
//        let decoder = JSONDecoder()
//        do {
//            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
//            let id = decodedData.weather[0].id
//            let temp = decodedData.main.temp
//            let name = decodedData.name
//
//            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
//            return weather
//
//
//        } catch {
//            delegate?.didFailWithError(error: error)
//            return nil
//        }
    
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
